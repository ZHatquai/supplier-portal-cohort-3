-- initial_schema: Supplier Sustainability Portal v2.0
-- Rules come from docs/access-matrix.md (short form, pattern P1):
-- RLS on every table, no policy for anyone, anon and authenticated hold no grants.
-- The only write path is the `submit` Netlify function (secret key), which calls create_submission().

-- updated_at helper
create or replace function public.set_updated_at()
returns trigger
language plpgsql
security invoker
set search_path = ''
as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

-- One row per confirmed submission
create table public.submissions (
  id uuid primary key default gen_random_uuid(),
  route text not null check (route in ('ecovadis', 'form', 'upload')),
  company_name text not null check (char_length(company_name) between 1 and 300),
  company_country text check (char_length(company_country) <= 200),
  contact_name text not null check (char_length(contact_name) between 1 and 200),
  contact_title text check (char_length(contact_title) <= 200),
  contact_email text not null check (char_length(contact_email) between 3 and 320),
  ecovadis_link text check (char_length(ecovadis_link) <= 2000),
  declaration_name text check (char_length(declaration_name) <= 200),
  declaration_date date,
  declaration_confirmed boolean not null default false,
  file_path text check (char_length(file_path) <= 500),
  reading_status text not null default 'not_applicable' check (reading_status in ('not_applicable', 'read')),
  company_key text not null check (char_length(company_key) between 3 and 600),
  status text not null default 'received' check (status in ('received', 'superseded')),
  created_by uuid,
  created_at timestamptz not null default now(),
  updated_by uuid,
  updated_at timestamptz not null default now(),
  constraint full_submission_has_declaration check (
    route = 'ecovadis'
    or (company_country is not null and declaration_name is not null
        and declaration_date is not null and declaration_confirmed)
  ),
  constraint upload_has_file check ((route = 'upload') = (file_path is not null)),
  constraint reading_status_matches_route check ((route = 'upload') = (reading_status = 'read'))
);

-- The database itself guarantees exactly one received row per company key
create unique index submissions_one_received_per_key
  on public.submissions (company_key) where status = 'received';

create trigger submissions_set_updated_at
  before update on public.submissions
  for each row execute function public.set_updated_at();

-- One row per question answered
create table public.submission_answers (
  id uuid primary key default gen_random_uuid(),
  submission_id uuid not null references public.submissions (id),
  question_id text not null check (question_id ~ '^S[1-7]-[1-6]$'),
  response text check (char_length(response) <= 4000),
  evidence_note text check (char_length(evidence_note) <= 4000),
  created_by uuid,
  created_at timestamptz not null default now(),
  updated_by uuid,
  updated_at timestamptz not null default now(),
  unique (submission_id, question_id)
);

create trigger submission_answers_set_updated_at
  before update on public.submission_answers
  for each row execute function public.set_updated_at();

-- RLS on, no policies, no grants for the public roles
alter table public.submissions enable row level security;
alter table public.submission_answers enable row level security;
revoke all on table public.submissions from anon, authenticated, public;
revoke all on table public.submission_answers from anon, authenticated, public;

-- Supersede and insert in one transaction. Called only by the submit function (service_role).
create or replace function public.create_submission(payload jsonb)
returns table (submission_id uuid, submitted_at timestamptz)
language plpgsql
security invoker
set search_path = ''
as $$
declare
  v_key text := payload->>'company_key';
  v_id uuid := coalesce((payload->>'id')::uuid, gen_random_uuid());
  v_created timestamptz;
begin
  if v_key is null or char_length(v_key) < 3 then
    raise exception 'company_key missing';
  end if;

  -- serialise submissions for the same key
  perform pg_advisory_xact_lock(hashtext(v_key));

  update public.submissions
     set status = 'superseded'
   where company_key = v_key and status = 'received';

  insert into public.submissions (
    id, route, company_name, company_country, contact_name, contact_title, contact_email,
    ecovadis_link, declaration_name, declaration_date, declaration_confirmed,
    file_path, reading_status, company_key
  ) values (
    v_id,
    payload->>'route',
    payload->>'company_name',
    nullif(payload->>'company_country', ''),
    payload->>'contact_name',
    nullif(payload->>'contact_title', ''),
    payload->>'contact_email',
    nullif(payload->>'ecovadis_link', ''),
    nullif(payload->>'declaration_name', ''),
    nullif(payload->>'declaration_date', '')::date,
    coalesce((payload->>'declaration_confirmed')::boolean, false),
    nullif(payload->>'file_path', ''),
    case when payload->>'route' = 'upload' then 'read' else 'not_applicable' end,
    v_key
  )
  returning created_at into v_created;

  insert into public.submission_answers (submission_id, question_id, response, evidence_note)
  select v_id, a->>'question_id', nullif(a->>'response', ''), nullif(a->>'evidence_note', '')
    from jsonb_array_elements(coalesce(payload->'answers', '[]'::jsonb)) as a;

  return query select v_id, v_created;
end;
$$;

revoke execute on function public.create_submission(jsonb) from public, anon, authenticated;
grant execute on function public.create_submission(jsonb) to service_role;
revoke execute on function public.set_updated_at() from public, anon, authenticated;

-- Private bucket for uploaded workbooks: 4 MB, .xlsx only, no storage policies (default deny)
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'submission-files', 'submission-files', false, 4194304,
  array['application/vnd.openxmlformats-officedocument.spreadsheetml.sheet']
)
on conflict (id) do nothing;
