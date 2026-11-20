# Supabase Setup: the-corporate-sustainability

**Last updated:** 20 November 2026, session 4 (spec v2.1)
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
| id | uuid | primary key, default gen_random_uuid() | the submit function supplies it |
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
| file_path | text | always null (check file_path_unused) | unused since v2.1: no file is stored; kept because a column is never dropped in an iteration |
| reading_status | text | not null, default not_applicable, in (not_applicable, read) | read if and only if route = upload |
| company_key | text | not null, 3 to 600 | lower-cased, trimmed company name and contact email, built by the function |
| status | text | not null, default received, in (received, superseded) | |
| created_by | uuid | nullable | login-ready column; empty until a login exists |
| created_at | timestamptz | default now() | |
| updated_by | uuid | nullable | login-ready column |
| updated_at | timestamptz | default now() | set by trigger |

Constraints: `full_submission_has_declaration` (route ecovadis, or country, declaration name, date and confirmation all present), `file_path_unused` (file_path is null; replaced `upload_has_file` in v2.1), `reading_status_matches_route`. Index: `submissions_one_received_per_key`, unique on company_key where status = received.

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
| storage | no bucket; no function calls storage; file_path always empty | check file_path_unused; submit refuses any file | #5 | built (bucket removal: builder, Storage page) |
| every table | anon nothing beyond line 1 | none | #6 | built, tested |

## 4. Triggers

| Name | Table | Event | What it does or refuses |
|---|---|---|---|
| submissions_set_updated_at | submissions | before update | sets updated_at |
| submission_answers_set_updated_at | submission_answers | before update | sets updated_at |
| ensure_rls (event trigger, platform-created) | any new table in public | ddl_command_end | enables RLS on every new public table automatically |

## 5. Functions

| Name | Security | Callable by (grant) | Checks first | Does |
|---|---|---|---|---|
| submit (Netlify Function) | secret key, server side | the public page | body at most 300 KB, no file, every field, the number rule for the seven Quantitative questions | builds company_key, normalises number answers, calls create_submission. No storage call. RLS does not apply to it; the function is the rule for this path |
| parse-workbook (Netlify Function) | no database access | the public page | .xlsx, at most 4 MB, sheet and row text match | returns the answers; stores nothing |
| public.create_submission(payload jsonb) | invoker, search_path fixed | service_role only (revoked from public, anon, authenticated) | company_key present; advisory lock on the key | supersedes the earlier received row, inserts the submission (never file_path, since v2.1) and its answers, returns id and created_at |
| public.set_updated_at() | invoker, search_path fixed | triggers only (execute revoked from public, anon, authenticated) | | sets updated_at |
| public.rls_auto_enable() | definer (platform-created) | nobody through the API (execute revoked from public, anon, authenticated) | | the ensure_rls event trigger's function |

## 6. Storage buckets

None since v2.1. The tool stores no file: an uploaded workbook is read in memory by `parse-workbook` and discarded. The v2.0 bucket `submission-files` (private, 4 MB, .xlsx) is emptied and deleted by the builder on the Supabase Storage page; Supabase refuses SQL deletes of stored files (`storage.protect_delete`), and forcing one would orphan the files, so this is a dashboard step. Status: see PROGRESS.md.

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

- Deleting a submission on a GDPR request: delete its submission_answers rows first (no cascade), then the submissions row; repeat for every row with the same company_key, superseded ones included. No file exists since v2.1.
- 20 November 2026: the builder's test rows (4 submissions, 120 answers) were deleted before the v2.1 migration; both tables were empty when it ran, so no export was needed.
- D15 (20 November 2026): an A Path row saved at 15:54:28 UTC was later deleted by hand (table statistics: 2 submission deletes, 0 answer deletes); nothing in the tool deletes.
- The Supabase security advisor reports "RLS enabled, no policy" (INFO) on both tables. That is intended: no role may read or write except the secret-key functions.
- The project was created by the builder with the platform's "auto-enable RLS" event trigger; it is kept.
- Rebuilding on a fresh project: the second migration revokes execute on public.rls_auto_enable(), a function the platform created with this project. On a project without it, skip that file (or create the project with the auto-enable RLS option).
- This container cannot reach supabase.co (network policy); the API-side refusal check runs from the Deploy Preview.

## 10. Change log

| Session | Date | Migration file | Change |
|---|---|---|---|
| 3 | 16 November 2026 | supabase/migrations/20261116155335_initial_schema.sql | tables submissions and submission_answers; RLS on, no policies; anon, authenticated and public grants revoked; one-received-per-key index; create_submission for service_role only; updated_at triggers; private bucket submission-files (4 MB, .xlsx) |
| 3 | 16 November 2026 | supabase/migrations/20261116155424_revoke_rls_auto_enable_execute.sql | execute on the platform's rls_auto_enable() revoked from public, anon, authenticated |
| 4 | 20 November 2026 | supabase/migrations/20261120163509_v2_1_no_file_storage.sql | check upload_has_file replaced by file_path_unused (file_path always null); create_submission no longer writes file_path; no table or column dropped or renamed (one check replaced) |
