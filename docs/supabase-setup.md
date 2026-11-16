# Supabase Setup: the-corporate-sustainability

**Last updated:** 16 November 2026, session 3
**Readable record since:** 16 November 2026. The migration files in supabase/migrations/ are what rebuilds this database; this file describes it.

## 1. Project

- Project name: the-corporate-sustainability
- Project ref: huahhrvlvkqktvvimylo
- Project URL: https://huahhrvlvkqktvvimylo.supabase.co
- Region: EU (Frankfurt), eu-central-1
- Plan: Free (build and test); switch to Pro before the first supplier wave
- Organization: SustainOS - AI Lab (created by the builder on 16 November 2026, empty when the build started)
- Population pattern: P1 public, stays anonymous (docs/access-matrix.md)
- Key system in use: publishable / secret. The project also carries the legacy anon key (enabled); this tool's code uses neither browser key. Values in Netlify are checked by the builder after the extension is connected.
- Tools on this project: Supplier Sustainability Portal (this one) only

## 2. Tables

### submissions (one row per confirmed submission)
| Field | Type | Constraint / default | Notes |
|---|---|---|---|
| id | uuid | primary key, default gen_random_uuid() | the submit function may supply it (upload: file path uses it) |
| route | text | not null, in (ecovadis, form, upload) | |
| company_name | text | not null, 1 to 300 characters | supplier |
| company_country | text | up to 200 | required for form and upload (constraint) |
| contact_name | text | not null, 1 to 200 | supplier |
| contact_title | text | up to 200 | optional |
| contact_email | text | not null, 3 to 320 | format checked in the function |
| ecovadis_link | text | up to 2000 | optional |
| declaration_name | text | up to 200 | required for form and upload |
| declaration_date | date | | required for form and upload |
| declaration_confirmed | boolean | not null, default false | must be true for form and upload |
| file_path | text | up to 500 | set if and only if route = upload |
| reading_status | text | not null, default not_applicable, in (not_applicable, read) | read if and only if route = upload |
| company_key | text | not null, 3 to 600 | lower-cased, trimmed company name and contact email, built by the function |
| status | text | not null, default received, in (received, superseded) | |
| created_by | uuid | nullable | login-ready column; empty until a login exists |
| created_at | timestamptz | default now() | |
| updated_by | uuid | nullable | login-ready column |
| updated_at | timestamptz | default now() | set by trigger |

Constraints: `full_submission_has_declaration` (route ecovadis, or country, declaration name, date and confirmation all present), `upload_has_file`, `reading_status_matches_route`. Index: `submissions_one_received_per_key`, unique on company_key where status = received.

### submission_answers (one row per question answered)
| Field | Type | Constraint / default | Notes |
|---|---|---|---|
| id | uuid | primary key | |
| submission_id | uuid | not null, FK to submissions.id (no cascade) | |
| question_id | text | not null, matches S1-1 to S7-6 pattern | the spec's 30 ids; the function accepts only those |
| response | text | up to 4000 | |
| evidence_note | text | up to 4000 | |
| created_by, created_at, updated_by, updated_at | | as above | login-ready and audit columns |

Unique (submission_id, question_id).

No profiles table: the spec names no login target yet.

Grants: `anon`, `authenticated` and `public` hold no grants on either table (revoked in the migration). `service_role` keeps the defaults and is used only by the Netlify functions.

## 3. Rules (per table, one line per rule, with its mechanism)

RLS is enabled on both tables. No policy exists for any role.

| Table | Rule in words | Mechanism | Matrix line | Status |
|---|---|---|---|---|
| submissions, submission_answers | anon creates only through the `submit` function; no policy, no grant | the submit function (secret key) calling create_submission | #1 | built; end to end pending the Netlify keys |
| submissions, submission_answers | anon reads nothing | none: no grant, no policy | #2 | built, tested |
| submissions | supersede: the earlier received row for the same company_key becomes superseded in the same transaction as the insert; one received row per key | create_submission + unique partial index | #3 | built |
| submissions, submission_answers | update and delete for everyone | none: default deny | #4 | built, tested |
| submission-files | private; no storage policy for any role; only the submit function stores files | bucket default deny | #5 | built, tested |
| every table and the bucket | anon nothing beyond lines 1 and 5 | none | #6 | built, tested |

## 4. Triggers

| Name | Table | Event | What it does or refuses |
|---|---|---|---|
| submissions_set_updated_at | submissions | before update | sets updated_at |
| submission_answers_set_updated_at | submission_answers | before update | sets updated_at |
| ensure_rls (event trigger, platform-created) | any new table in public | ddl_command_end | enables RLS on every new public table automatically |

## 5. Functions

| Name | Security | Callable by (grant) | Checks first | Does |
|---|---|---|---|---|
| submit (Netlify Function) | secret key, server side | the public page | fields part at most 300 KB, file at most 4 MB and .xlsx and readable as the workbook, every field | builds company_key, stores the file (upload), calls create_submission; removes its own stored file if the insert fails. RLS does not apply to it; the function is the rule for this path |
| parse-workbook (Netlify Function) | no database access | the public page | .xlsx, at most 4 MB, sheet and row text match | returns the answers; stores nothing |
| public.create_submission(payload jsonb) | invoker, search_path fixed | service_role only (revoked from public, anon, authenticated) | company_key present; advisory lock on the key | supersedes the earlier received row, inserts the submission and its answers, returns id and created_at |
| public.set_updated_at() | invoker, search_path fixed | triggers only (execute revoked from public, anon, authenticated) | | sets updated_at |
| public.rls_auto_enable() | definer (platform-created) | nobody through the API (execute revoked from public, anon, authenticated) | | the ensure_rls event trigger's function |

## 6. Storage buckets

| Bucket | Public / private | Path pattern | Max size / types | Upload | Read | Delete |
|---|---|---|---|---|---|---|
| submission-files | private | [submission id]/[original file name] | 4 MB / application/vnd.openxmlformats-officedocument.spreadsheetml.sheet | the submit function only | the platform owner in the dashboard | none through the app |

## 7. Auth

- Status: none yet. Nobody logs in. No Auth setting was changed.

## 8. Environment variable names this project expects (never values)

| Name | Read by | Set where | Public or secret |
|---|---|---|---|
| VITE_SUPABASE_URL | the Netlify Functions (project address) | Netlify env (extension) | public |
| VITE_SUPABASE_ANON_KEY | nothing in this tool | Netlify env (extension); value = publishable key | public |
| SUPABASE_SERVICE_ROLE_KEY | the Netlify Functions | Netlify env (extension); value = secret key | secret |
| SUPABASE_DATABASE_URL | nothing | Netlify env (extension) | secret |

To be verified once the builder connects the extension; corrected here if the names differ.

## 9. Notes and flags for future sessions

- Deleting a submission on a GDPR request: delete its submission_answers rows first (no cascade), then the submissions row, then its file in submission-files; repeat for every row with the same company_key, superseded ones included.
- The Supabase security advisor reports "RLS enabled, no policy" (INFO) on both tables. That is intended: no role may read or write except the secret-key functions.
- The project was created by the builder with the platform's "auto-enable RLS" event trigger; it is kept.
- Rebuilding on a fresh project: the second migration revokes execute on public.rls_auto_enable(), a function the platform created with this project. On a project without it, skip that file (or create the project with the auto-enable RLS option).
- This container cannot reach supabase.co (network policy); the API-side refusal check runs from the Deploy Preview.

## 10. Change log

| Session | Date | Migration file | Change |
|---|---|---|---|
| 3 | 16 November 2026 | supabase/migrations/20261116155335_initial_schema.sql | tables submissions and submission_answers; RLS on, no policies; anon, authenticated and public grants revoked; one-received-per-key index; create_submission for service_role only; updated_at triggers; private bucket submission-files (4 MB, .xlsx) |
| 3 | 16 November 2026 | supabase/migrations/20261116155424_revoke_rls_auto_enable_execute.sql | execute on the platform's rls_auto_enable() revoked from public, anon, authenticated |
