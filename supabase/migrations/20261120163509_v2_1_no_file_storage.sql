-- v2.1 (spec Section 5, 9): the uploaded workbook is never stored.
-- file_path stays as a column (no drop or rename in an iteration) but must always be empty.
-- The check that required a file on uploads is replaced; no data is held in it (both tables were empty).
-- The bucket submission-files is removed by the builder on the Supabase Storage page:
-- Supabase refuses SQL deletes of stored files, and a forced SQL delete would orphan the files.

alter table public.submissions drop constraint upload_has_file;
alter table public.submissions add constraint file_path_unused check (file_path is null);
comment on column public.submissions.file_path is 'Unused since v2.1: no file is stored; always empty (check file_path_unused).';

-- create_submission: same transaction, supersede and inserts as before, without file_path.
create or replace function public.create_submission(payload jsonb)
returns table (submission_id uuid, submitted_at timestamptz)
language plpgsql
set search_path = ''
as $function$
declare
  v_key text := payload->>'company_key';
  v_id uuid := coalesce((payload->>'id')::uuid, gen_random_uuid());
  v_created timestamptz;
begin
  if v_key is null or char_length(v_key) < 3 then
    raise exception 'company_key missing';
  end if;

  perform pg_advisory_xact_lock(hashtext(v_key));

  update public.submissions
     set status = 'superseded'
   where company_key = v_key and status = 'received';

  insert into public.submissions (
    id, route, company_name, company_country, contact_name, contact_title, contact_email,
    ecovadis_link, declaration_name, declaration_date, declaration_confirmed,
    reading_status, company_key
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
    case when payload->>'route' = 'upload' then 'read' else 'not_applicable' end,
    v_key
  )
  returning created_at into v_created;

  insert into public.submission_answers (submission_id, question_id, response, evidence_note)
  select v_id, a->>'question_id', nullif(a->>'response', ''), nullif(a->>'evidence_note', '')
    from jsonb_array_elements(coalesce(payload->'answers', '[]'::jsonb)) as a;

  return query select v_id, v_created;
end;
$function$;

revoke execute on function public.create_submission(jsonb) from public, anon, authenticated;
grant execute on function public.create_submission(jsonb) to service_role;
