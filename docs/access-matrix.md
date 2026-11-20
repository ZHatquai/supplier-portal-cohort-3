# Access Matrix: Supplier Sustainability Portal

**Written against:** product-spec.md v2.1 · supabase-setup.md as of 16 November 2026 (short run, revised for v2.1)
**Population pattern:** P1 public, stays anonymous
**Date:** 20 November 2026
**Author:** Zyad Hatquai
**Status:** Confirmed
**Companion file:** user-stories.md

> The source of truth for who may do what. The Project Governor lifts Section 7 into CLAUDE.md. Claude Code builds the database with the rules in Section 6 from the first table, using the mechanism each line names. The handover ships this file unchanged.
>
> This is the short form: nobody logs in yet, so the rules are fixed and final until someone does. The full run (named people, ownership, states, the seven actions in full, the policy plan for logged-in users) happens when the dashboard is specced and docs/supabase-setup.md exists.
>
> Every cell names a real table and one of the seven actions. A screen or route is never a cell. Export never exceeds read.
>
> v2.1 revision (20 November 2026): the tool stores no file. The storage bucket, its rules and its refusal tests are removed; the `submit` function also refuses any request that carries a file. The write-only rules for the two tables are unchanged.

---

## 1. The matrix

Legend: `yes` = all rows · `no` = refused, in the database, not only in the screen.

Pattern P1: the only population today is the public visitor, `anon`. **No anon policy and no anon grant exists on any table, and no storage bucket exists.** The visitor creates a submission **only through the `submit` function**, a Netlify Function that holds the secret key, refuses an oversized body, refuses any file, validates every field and does the inserts. The browser never talks to Supabase. Bot check: not in this version (spec Section 3, Section 15).

Actions in this order: create, read, update, change state, delete, export, maintain lists.

### submissions (one row = one confirmed submission: an EcoVadis short entry, a form submission or the confirmed answers of an upload)

| Action | anon (no login) |
|---|---|
| create | yes, through the `submit` function only |
| read | no |
| update | no |
| change state (received to superseded) | no; done by the `submit` function in the same step as the new insert, never requested by the visitor |
| delete | no |
| export | no |
| maintain lists | not applicable |

### submission_answers (one row per question answered)

| Action | anon (no login) |
|---|---|
| create | yes, through the `submit` function only, in the same step as its submission |
| read | no |
| update | no |
| change state | not applicable |
| delete | no |
| export | no |
| maintain lists | not applicable |

### storage buckets

None (since v2.1). The tool stores no file: an uploaded workbook is read by `parse-workbook` and discarded, and the answers the supplier confirms are the submission. The v2.0 bucket `submission-files` is emptied and removed. No bucket means no bucket rule; adding a bucket later is a spec change and a revision of this matrix.

### `parse-workbook` function

It reads an uploaded workbook and returns its answers to the page. It reads and writes no table and no storage, so it adds no cell. Its rule is: store nothing, keep nothing.

---

## 2. Ownership

Not yet: nobody logs in. A row has no owner until a login exists. `created_by` exists on both tables and stays empty.

## 3. The people

| Role | Named first holder | Layer | Screens |
|---|---|---|---|
| anon, the public visitor | no name | outside the app | the page (the form, the upload, the review and confirm screen, the A Path short entry) |
| platform owner | Zyad Hatquai (own Netlify and Supabase accounts) | outside the app | Supabase, Netlify dashboards |

No business role, no admin flag and no profiles table exist in this build. The first dashboard reader is not named yet (spec Section 15). Until the dashboard exists, the platform owner reads submissions in the Supabase dashboard (no files are stored).

## 4. Exceptions

Not yet: nobody logs in. No column-level rule applies today.

## 5. Schema delta

Not yet. The Governor seeds the login-ready columns on both tables from day one: `created_by` (empty until a login exists), `status`, `created_at`, `updated_by` (empty), `updated_at`. No `profiles` table is created: spec Section 6 names no login target yet. The full run adds it as a migration, not a rebuild.

---

## 6. Policy plan (short form)

Written in words. Claude Code writes the SQL. Every line names its mechanism.

| # | Table | Action | Role | Rule in words | Mechanism | Test |
|---|---|---|---|---|---|---|
| 1 | submissions, submission_answers | create | anon | the visitor writes only through the `submit` function: it holds the secret key, refuses a body over 300 KB, refuses any request that carries a file, validates every field (required fields, email shape, 4,000 characters per answer or note, only the 30 known question ids, the route value, the number rule for the seven Quantitative questions), and does the inserts. No anon policy and no anon grant. Because the secret key bypasses RLS, the function is the rule for this path and does nothing except the validated inserts and the supersede step. | the `submit` function; default deny for everything else | a logged-out visitor submits through the page and one row exists; a direct insert from the browser or the API with the publishable key is refused |
| 2 | submissions, submission_answers | read | anon | nothing returned: no policy, no grant | none (default deny) | a direct read from the browser or the API returns a permission error, not an empty list; no screen shows a stored record |
| 3 | submissions | change state (supersede) | anon | a submission is never edited. A new one with the same company key (company name and contact email, lower-cased and trimmed) flips the earlier `received` row to `superseded` in the same step as the insert; exactly one `received` row exists per key. Done by the function, never by the visitor. | the `submit` function | submitting twice with the same company and email leaves one `received` and one `superseded` row; the visitor has no edit screen and a direct update is refused |
| 4 | submissions, submission_answers | update, delete | everyone | no policy anywhere | none (default deny) | no update or delete works from any account through the API |
| 5 | storage | any | everyone | no bucket exists; no function has a storage call; `submissions.file_path` is always empty (a database check) | none: nothing to protect; the `submit` function refuses any file | listing buckets with the publishable key and with no key finds nothing; a request to `submit` that carries a file is refused and saves nothing |
| 6 | every table | any | anon | nothing except what line 1 states through the function | none (default deny; the function is the write path) | with the publishable key and with no key, every read, insert, update and delete is refused |

Default deny applies to every table; no bucket exists. RLS is enabled on both tables from the moment they are created and is never disabled.

**The gate (short form).** Before the first public deploy, Claude Code tries every `no` cell through the API with the publishable key and with no key (REST, and a bucket listing through the Storage URL) and pastes the results into PROGRESS.md under "Refusal test record". Half B (named people on screens) does not apply yet: nobody logs in. From the builder's side, after confirming a submission on the Deploy Preview, a supplier cannot see, fetch or list their own submission.

**P1 note.** There is no cutover rule: suppliers stay anonymous. If suppliers get accounts later, that is a spec change and the pattern becomes P3 in that change.

---

## 7. Hard rules for CLAUDE.md (the Governor lifts these verbatim)

1. The refusal happens in the database, or in a server function that holds the secret key and checks every request itself; never only in the screen. A hidden button is not a rule. RLS is enabled on every table and never disabled to make something work. `anon` has no policy and no grant on any table, and no storage bucket exists; the public page writes only through the `submit` function. A function that holds the secret key bypasses RLS, so for its path the function is the rule: it validates every field, refuses any file, and does nothing but the validated inserts and the supersede step. The browser never talks to Supabase.
2. No user can change their own `role`, `is_admin` or `active` through the app. No such columns or profiles exist in this build; when a login arrives, a trigger refuses it and the platform owner sets them from the Supabase dashboard.
3. A submission is never edited, by anyone, admin included: its only change is `received` to `superseded`, done by the `submit` function. A correction is a new submission. When an admin exists, withdraw, reinstate and anonymise run through narrow functions, never a free edit.
4. Nothing is deleted through the app: no `DELETE` policy exists on any table. A GDPR deletion request is actioned by the platform owner, who deletes every submission from that company and contact email (all `received` and `superseded` rows and their answer rows; no file is stored) in the Supabase dashboard or with a Claude Code admin command, and confirms to the requester. Copies already exported are outside the tool.
5. Every record table carries `created_by`, `created_at`, `updated_by`, `updated_at`. The history of a submission is its superseded rows, kept until deleted on request; no separate history table is built because no row is ever edited.

---

## 8. Handover paragraph (for the handover package, plain language)

The Supplier Sustainability Portal has one kind of user: the public visitor. A supplier opens the page, fills in the form or uploads the filled workbook, reviews the answers and confirms, and the page saves them through a server function. An uploaded workbook is only read to fill in the answers; the file itself is never kept. Nobody logs in. The supplier cannot read, change or delete anything afterwards, including their own submission; submitting again with the same company name and contact email replaces the earlier one, which is kept as superseded. The rules are enforced in the database itself: no table can be read or written from the browser, and no file store exists, only the one server function can write. Until a dashboard exists, Zyad Hatquai, who holds the Supabase and Netlify accounts, reads submissions in the Supabase dashboard; moving those accounts to a company account changes nothing in the rules. There is no rate limit and no bot check in this version: the page is protected by a size limit and field checks, and the bot check is the step to add before sharing the link beyond testing.
