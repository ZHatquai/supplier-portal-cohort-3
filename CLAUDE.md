# Supplier Sustainability Portal

## Identity
A public web page that explains The Corporate's supply chain sustainability programme to Tier 1 suppliers and lets each supplier act on the page itself: record an EcoVadis scorecard (A Path) or submit the questionnaire by form or by uploading the filled Excel workbook (B Path). Anyone with the link can use it.
Tier: 2, a public page with a form and an upload, data persists to Supabase, no login (D3+A1)
Spec version governed: v2.0 (docs/product-spec.md)
Position: Standalone. A later dashboard is a second view of this tool, not a second tool.

## Session Protocol
You open in plan mode (.claude/settings.json). You read and propose; you change nothing until the builder approves the plan.

At the start of every session:
1. Pull the latest from main first.
2. Never work on main, never push to main, never merge. In a cloud session work on the branch the session is on (`claude/...`); locally create one named for the intent. Every session ends with a pull request the builder merges.
3. If docs/product-spec.md is newer than "Spec version governed" above, STOP: "The spec has changed since this CLAUDE.md was written. Re-run the Project Governor on the revised spec before building."
4. Read PROGRESS.md (recreate it with the structure below if missing) and docs/checks.md, which defines "done".
5. Increment the session number and date in PROGRESS.md. Read any "Notes for next session" aloud, treat them as priorities, then clear them.
6. Plan first. State the lane: **fix** (the tool is not yet what the spec says) or **change** (the tool would become something the spec does not say: someone new sees or does something, something new is remembered, a new screen, arm or connection). A change whose spec version has not moved past the governed one: STOP. Tell the builder: "That is a change, so it needs its own session. Start a new session and describe it in your own words; the Tool Architect, the Project Governor and the build happen in that one session." Offer to add it to the Backlog. Otherwise propose the plan (what changes, in what order, which rows of docs/checks.md prove it, what could break), wait for approval, write it into PROGRESS.md "Plan for this session", then build.

Save point, after any module, feature, fix or schema change:
1. Update PROGRESS.md (state, remaining work, decisions, known issues).
2. If the database was touched, update docs/supabase-setup.md in the same save point; the change's migration file is in supabase/migrations/ and committed with it.
3. Commit and push the branch, then confirm it reached GitHub (`git ls-remote origin <branch>` shows your commit). Never report a push you have not confirmed.
4. Tell the builder in one line: "Save point pushed: [what changed]." Do not start the next piece before this. An ending session is a save point.

Done means the checks pass. At the end of every phase: run every row of docs/checks.md you can perform and write the result and date in Last result (fix the tool, never the row); run the verifier agent and paste its report under "Check results" in PROGRESS.md; report the phase done only when both pass.

End of the session, one pull request:
1. Push the branch and confirm it. Open the pull request (tool, `gh pr create`, or the prefilled link https://github.com/ZHatquai/supplier-portal-cohort-3/compare/main...[branch]?expand=1) and give the builder its link: Netlify builds a Deploy Preview on it.
2. Tell the builder: "Open the Deploy Preview, then say *checks* and I'll give you the list." On request give every builder row of docs/checks.md for this change as one numbered list of actions (what to open or do, what they should see), no questions inside it. Record results in docs/checks.md and PROGRESS.md; fix failures in this session. A decision for the builder is its own question.
3. Run the reviewer agent on the branch; fix every blocker; record its findings in PROGRESS.md.
4. When the rows pass: "All checks pass. Merge the pull request and delete the branch; the live site updates." You never merge.
5. After the merge, check the live site loads, then: "This session is done. For the next idea or change, start a new session."

PROGRESS.md structure: status header (Session, Last updated, Live URL, First deploy, Stage, Supabase project), Plan for this session, Current state, Last session, Remaining work, Check results, Refusal test record, Build decisions, Known issues, Backlog, Notes for next session.

## Commands
```
npx serve site
```
The two functions are tested locally with the Netlify CLI (`npx netlify dev`, no Netlify login); confirm the exact command in the plan.

## Tech Stack
HTML · CSS · JavaScript (no framework, no build step for the page) · Netlify (static site plus two Netlify Functions in netlify/functions/, Node, one package.json for their dependencies) · Supabase
Deployment: GitHub push, Netlify auto-deploys. You work on a branch and push it; the builder opens the pull request, checks the Deploy Preview against docs/checks.md, the reviewer passes, the builder merges on GitHub and deletes the branch; main deploys. You never connect to Netlify and no Netlify connector or MCP is used. The builder connects Supabase to the Netlify site once with the Supabase extension, after you create the project; it writes the Supabase variables into the site's environment; then a redeploy. If a variable is missing at runtime, the fix is the extension connection, never a value pasted anywhere.

## Environment Variables
From the spec's contract. Written by the Supabase extension; values checked once by the builder (they start with `sb_`; the variable names are historical):
VITE_SUPABASE_URL: the Netlify Functions' project address, public (the page does not use it)
VITE_SUPABASE_ANON_KEY: written by the extension, public, publishable key; no code in this tool uses it
SUPABASE_SERVICE_ROLE_KEY: Netlify Functions only, SECRET, its value is the secret key (`sb_secret_...`); never VITE_-prefixed
SUPABASE_DATABASE_URL: secret, unused unless a function needs a direct connection
If the extension writes different names or `eyJ` values, tell the builder, record the real names in docs/supabase-setup.md section 8; a legacy secret key keeps working until rotated (a handover item). No value ever appears in code or in any committed file. At session start confirm these exist before first use.

## Supabase
Project: "the-corporate-sustainability" (new, EU region Frankfurt, because personal data of suppliers' staff is stored). At the start of the build session, if PROGRESS.md shows it is not created, confirm the name with the builder, create it via Supabase MCP before building anything, and record the ref in PROGRESS.md and docs/supabase-setup.md. Plan: Free for building and testing (no backups, pauses after about a week unused); the switch to Pro is a manual billing step due before the first supplier wave.
Every schema, policy, trigger and function change goes through `apply_migration` with a descriptive name AND is saved as supabase/migrations/[timestamp]_[name].sql in the repo, committed with the save point. `execute_sql` is for reads and data fixes only.
Build this schema, authoritative until docs/supabase-setup.md exists:
submissions: id, route (ecovadis | form | upload), company_name, company_country, contact_name, contact_title, contact_email, ecovadis_link, declaration_name, declaration_date, declaration_confirmed, file_path, reading_status (not_applicable | read), company_key, status (received | superseded, default received), created_by (empty until a login exists), created_at, updated_by, updated_at
submission_answers: submission_id (FK to submissions.id), question_id (S1-1 to S7-5, per the spec's question list), response, evidence_note (each at most 4,000 characters)
Storage bucket: submission-files, private, max 4 MB per file, .xlsx only, path [submission id]/[file name]
No profiles table: the spec names no login target.
RLS: enabled on both tables the moment they are created; never disabled. Population pattern P1, public stays anonymous. `anon` has no policy and no grant on any table or on the bucket (revoke after creating each table). Every rule lives in docs/access-matrix.md (short form); build each line of its policy plan with the mechanism it names and never loosen a table to make a screen work. anon: create only, through the `submit` function; no read, update, delete or export. The supersede step runs in the `submit` function in the same step as the insert. The `submit` function (netlify/functions/submit) is the rule for its path: RLS does not apply to the secret key, so it refuses a request whose fields exceed 300 KB or whose file exceeds 4 MB, validates every field, and does only the validated inserts, the supersede step and the file upload. `parse-workbook` reads an uploaded file and returns its answers; it touches no table and no bucket and keeps nothing.
After setup write docs/supabase-setup.md and update it at every save point that touches the database. Structure, in this order: (1) header: project name, ref, URL, region, plan, key system, pattern; (2) tables with fields, types, constraints; (3) rules per table, one line each with its mechanism and matrix line; (4) triggers; (5) functions with who may call them and what they check; (6) buckets; (7) Auth ("none yet"); (8) environment variable names; (9) notes and flags; (10) change log, one line per migration file.

## Hard Rules
- API keys never in any frontend file or GitHub commit. The secret key lives only in the Netlify environment and is read only inside the two functions. The browser never talks to Supabase and the page loads no Supabase library.
- Netlify Identity: never. Supabase Auth is the only authentication system, and none is configured: nobody logs in.
- RLS on every table from creation, never disabled. If a query fails, fix the policy or the query. `anon` has no policy and no grant on any table or bucket. No screen reads a stored record: suppliers never read anything back.
- Migrations: through `apply_migration`, saved as files in supabase/migrations/; additive only in an iteration (never drop or rename in the same change). Before a migration touches a table that holds real rows, export it to a file outside the repo and tell the builder where. There is no preview database; the Deploy Preview talks to the live one, so data checks create and then clean up their own test rows.
- Function contract: a Netlify function holding the secret key validates every input and returns only the fields the spec names. Any database function is SECURITY INVOKER unless it must write a protected column; exceptions are SECURITY DEFINER with `SET search_path = ''`, check auth.uid() first, REVOKE EXECUTE FROM public, anon.
- Every access rule comes from docs/access-matrix.md. If a query needs a rule it does not state, stop and tell the builder to revise the matrix.
- Public endpoint protections: every public write goes through `submit`; it also refuses anything but .xlsx for the file and an answer or note over 4,000 characters. None of these is optional. There is no rate limit; do not build one.
- Public form without a bot check: known risk, see the spec; do not add one unless the builder asks.
- The visitor's IP is never stored in any table or written to a log. If asked for duplicate detection or abuse tracking, the answer is the supersede rule, not an IP column.
- Nothing is saved before the supplier confirms. Reading an uploaded file saves no row and no file. A submission is never edited by anyone; its only change is received to superseded, made by `submit`.
- GDPR applies. Lawful basis: contract or legitimate interest (the privacy contact signs it off). Show the confirmed data notice (spec Section 7) wherever personal data is entered. No consent checkbox. Personal data: contact name, title, email, signatory name, anything typed in free text or in an uploaded file. Retention: until deleted on request. Deletion requests go to inbox@thecorporate.com and are actioned by the platform owner, who deletes every submission from that company and contact email (rows, answers, files) in the Supabase dashboard or with a Claude Code admin command. Supabase region: EU (Frankfurt).
- No cookies, no tracking, no analytics, no script beyond the page's own. The only external resource the page loads is the Google Fonts stylesheet. No exclamation points. The v1.0 footer line "This page does not collect or store any information about you" must not appear.
- Complexity: build no rate limit, queue, retry, scan, monitor or test framework. If a request asks for one, put it on the Backlog as "not in place; what it would take" and tell the builder. The checks in docs/checks.md are not a framework and are never skipped.
- Done means the checks pass: no phase is done and no branch is handed over until its rows in docs/checks.md pass and the verifier agrees. Never edit docs/checks.md, docs/access-matrix.md or docs/user-stories.md to make a check pass.
- Branch rule: never push to main, never merge. One branch, pushed and confirmed, one pull request per session. One intent per session.
- Never copy text from docs/ or reference/ that the spec's Section 8 does not list for the page. The Charter and Strategy are confidential; the page uses only what Section 8 states.

## Things Claude gets wrong
Read this before every save point. When the builder corrects the same mistake a second time, add it here as one line, in that session, before anything else.
- Writing a key value into a file or a command. Keys live in Netlify's environment; only the variable NAME appears elsewhere.
- Adding a figure, role or rule from the confidential Charter or Strategy that Section 8 does not list (for example the 690,000 tCO2e total, RACI roles, the 15-business-day triage rule, "escalated").
- Disabling RLS, adding an anon policy, or loosening a table to make a screen work. Every rule comes from docs/access-matrix.md.
- Reporting a phase done without running its rows in docs/checks.md and the verifier.

## Project Structure
Root: CLAUDE.md, PROGRESS.md, netlify.toml, package.json (function dependencies) · site/ (deployed: index.html, about.html, css/, js/, assets/, downloads/) · netlify/functions/ (parse-workbook, submit) · supabase/migrations/ · fixtures/ (test files for the data checks, never served) · docs/ (intent notes, product-spec.md, checks.md, access-matrix.md, user-stories.md, supabase-setup.md) · reference/ (workbook, never edited) · .claude/ (settings.json, skills/the-corporate-brand/)

## Brand
Brand is governed by The Corporate brand skill at .claude/skills/the-corporate-brand/SKILL.md. Invoke it before any UI or copy work. Hard rules that hold even if it is not loaded:
- Background: Chalk #F2F2F2; surfaces Linen #EAE4D5 and White; text Ink #000000; muted Stone #B6B09F
- Accent: Acid Lime #C8F135, only against Ink, exactly twice on the page (the deadline badge, the question panel's 2px left border). The new form, review and error screens add no lime and no red: errors are Ink text on Linen with a 0.5px Ink border. Never Tailwind blue defaults.
- Fonts: Playfair Display for headlines, DM Sans (300 body) for all other text, from Google Fonts
- Square corners, 0.5px hairline borders, no shadows, no gradients, no emoji, no exclamation points, no em dashes in prose, dates as DD Month YYYY
- No logo files exist in the repo: draw the logo (black square with "C", wordmark THE CORPORATE in DM Sans Light, 0.12em tracking) as inline SVG or CSS.

## Business Rules
- The question "Do you have an EcoVadis Scorecard?" starts section 04 with neither path visible. Yes shows the A Path, No shows the B Path, switching replaces the visible path, nothing is stored in the browser, and a reload returns to the neutral state.
- A Path: a short entry (company name, contact name, contact email required; scorecard link optional) saved through `submit` with route `ecovadis`, no answer rows. Then "Go to EcoVadis": `https://ecovadis.com`, `target="_blank"`, `rel="noopener noreferrer"`, never an automatic redirect. If saving fails, show the error and Try again, keep the typed entries, and still offer the EcoVadis link.
- B Path: the workbook download stays, served unchanged from reference/The_Corporate_Supplier_Questionnaire_2026_39.xlsx at /downloads/The_Corporate_Supplier_Questionnaire_2026.xlsx (copy in site/downloads/, forced download). Two ways to submit, neither preselected: the form (30 questions, S1 to S7, the spec's question list, dropdown options read from the workbook, never invented) or an upload. Both end on Review and confirm, then Confirmation with the date. No "Return by email" and no mailto link; inbox@thecorporate.com appears only as text.
- Upload: .xlsx only, at most 4 MB; sheet "Supplier Assessment 2026"; the 30 question rows must sit at the rows in the spec with matching text, else the error "We could not read this file. Please use the questionnaire downloaded from this page, or fill in the form instead." and nothing is saved. Responses from column E, notes from column F; column G ignored; the declaration is never read from the file.
- Required: company name, country, contact name, contact email, and the declaration (signatory name, date, confirmation tick). Everything else is optional. Each answer and note is at most 4,000 characters.
- Supersede: key = company name plus contact email, lower-cased and trimmed. A new submission flips the earlier `received` row to `superseded`; exactly one `received` row per key; superseded rows are kept.
- Footer line: "Data you submit on this page is stored by The Corporate. This page uses no cookies and no tracking." plus a link to About this tool (about.html).
- Cycle dates are the 2027 cycle: April 2027, 30 September 2027, Q4 2027, Q1 2028. No 2026 date appears. Named documents keep their 2026 titles.
- Figures on the page are only 71%, 500+, 2045 and 50% (by 2030 against 2023). No tCO2e totals, internal roles or escalation rules.
- English only. Every control works by keyboard; the page works from 360px wide with no horizontal scroll; buttons at least 44px tall.

Out of scope, do not build:
- The dashboard showing every submission, its login and reading role (a later change, v3.0); supplier login and saved progress, including saving a half-finished form
- Supplier editing or withdrawing a submission after confirming
- Email notices or confirmation emails; a bot check; any rate limit, queue, retry, virus scan or monitoring
- Automated scoring or an automatic PFAS flag; in-tool Scope 3 calculation; programmatic EcoVadis validation
- Languages other than English; links to the Supplier Code of Conduct and Global Environmental Policy (no URLs yet)

## Reference Docs
Read before building the related part:
- docs/intent.md and docs/intent-2026-11-16.md: why the tool exists and why it changed, in the originator's words
- docs/product-spec.md: every view, the question list, the copy points, the checks, the open questions
- docs/checks.md: what done means; run its rows, never edit them
- docs/supabase-setup.md: schema source of truth (created in the build session)
- docs/access-matrix.md: read before writing any RLS or touching a policy (short form: anon rules only)
- docs/user-stories.md: read before changing a screen; every acceptance line is a test
- .claude/skills/the-corporate-brand/SKILL.md: the full brand system
PROGRESS.md in the root is read at every session start.
