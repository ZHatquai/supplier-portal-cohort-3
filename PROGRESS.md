# PROGRESS: Supplier Sustainability Portal

> Claude Code: read this file at the start of every session, before touching anything. Update it at every save point. Replace content, do not append. History lives in git.

**Session:** 2
**Last updated:** 16 November 2026
**Live URL:** https://supplier-portal-cohort-3.netlify.app/ [Rule: fill in after the first successful deploy]
**First deploy:** 9 November 2026 [Rule: the date the first pull request was merged with all builder checks passing; a record only]
**Stage:** business logic and database [Rule: one of business logic and database / second screen and access design / login and access rules together / deploy and maintain. Decided by what exists, never by a week or version.]
**Supabase project:** not yet created. Confirm the name "the-corporate-sustainability" (EU, Frankfurt) with the builder and create it in the build session. [Rule: the only place project existence is recorded]

## Plan for this session
None yet. [Rule: Claude Code opens in plan mode, states the lane, proposes the plan and writes the approved plan here (3 to 8 lines). Replaced each session.]

## Current state
The page is live at https://supplier-portal-cohort-3.netlify.app/ as v1.0, deployed from main after pull request 2 was merged on 9 November 2026. Site in site/ (index.html, css/styles.css, js/main.js, downloads/ with the workbook, byte-identical to reference/). All six blocks present: hero, 01 to 04, footer. Data checks D1 to D7 of v1.0 pass; the builder reports all builder checks done on the Deploy Preview. v2.0 (submission through the tool) is specced but not built: spec, access matrix and user stories are written and this file, CLAUDE.md and docs/checks.md govern it. Claude Code could not load the live site from the cloud session (network policy), so the live load check is the builder's.
[Rule: describes what exists and works right now, never what is planned. Completed checklist items are absorbed here in compressed form.]

## Last session
Session 2 (16 November 2026): record-keeping, then the change to v2.0 specced in the same session: spec v2.0, access matrix (short form, pattern P1) and user stories, regenerated CLAUDE.md and docs/checks.md. No site changes yet.
[Rule: 3 to 5 lines maximum. Replace each session.]

## Remaining work
- [ ] Before launch (see Known issues): sign-off owner, A Path link, workbook final for the 2027 cycle
- [ ] (v2.0 revision) Update netlify.toml: add the functions directory, keep `publish = "site"` and the download header; add package.json for the function dependencies
- [ ] (v2.0 revision) Create Supabase project "the-corporate-sustainability" via MCP (EU region); confirm the name with the builder first; record the ref in the header above
- [ ] (v2.0 revision) Build submissions, submission_answers and the private bucket submission-files (named migrations saved in supabase/migrations/, RLS on from creation, login-ready columns, anon grants revoked, rules from docs/access-matrix.md), no Auth; then write docs/supabase-setup.md following the structure in CLAUDE.md
- [ ] (v2.0 revision) Build the `parse-workbook` function and the fixtures in fixtures/ (reads the upload, saves nothing) then run D8 to D10 and the verifier
- [ ] (v2.0 revision) Build the `submit` function: public endpoint protections before the first public deploy (field limits, validation, .xlsx and size limits, supersede step) then run D11 to D15 and the verifier
- [ ] (v2.0 revision) Update 03 How this works (Route B text) then run its rows in docs/checks.md and the verifier
- [ ] (v2.0 revision) Build 04 A Path: short entry, confirmation, "Go to EcoVadis" then run its rows and the verifier
- [ ] (v2.0 revision) Build 04 B Path: workbook download kept, the two-ways choice, the form of 30 questions then run its rows and the verifier
- [ ] (v2.0 revision) Build 04 B Path: upload and reading of the workbook then run its rows and the verifier
- [ ] (v2.0 revision) Build Review and confirm, Confirmation and the error messages then run its rows and the verifier
- [ ] (v2.0 revision) Show the confirmed data notice wherever personal data is entered (no consent checkbox)
- [ ] (v2.0 revision) Update the footer (data line, About link, no v1.0 privacy line) then run its rows and the verifier
- [ ] (v2.0 revision) Build About this tool (about.html), last, then run its screen check
- [ ] (v2.0 revision) Refusal test, half A: try every `no` cell through the API with the publishable key and with no key; paste the results under Refusal test record
- [ ] (v2.0 revision) Checks pass for this stage: every row of docs/checks.md shows a pass dated today; the verifier's report pasted under Check results
- [ ] (v2.0 revision) Builder: connect Supabase to the Netlify site with the Supabase extension (after the project exists), check the key values start with `sb_`, then redeploy
- [ ] (v2.0 revision) Push the branch and confirm it reached GitHub; open the pull request and give the builder its link
- [ ] (v2.0 revision) Builder checks: on request, the builder rows of docs/checks.md as a numbered list of actions; record the results; fix failures in this session
- [ ] (v2.0 revision) Reviewer pass on the branch: blockers fixed, findings recorded; report ends "Safe to merge"
- [ ] (v2.0 revision) Builder: merge the pull request and delete the branch, then main deploys. Claude Code never merges. Check the live site loads.
- [ ] (v2.0 revision) Builder: upgrade the Supabase project to Pro in the dashboard before the first supplier wave; Free has no backups and pauses when idle
[Rule: completed items leave this list and are absorbed into Current state. This list only shrinks.]

## Check results
9 November 2026, verifier, branch claude/keen-gates-p71k7k: D1 to D7 PASS; S1, S2, S4, S5, S10, S12 PASS; secrets clean; no protected files edited. Findings fixed after the report: the "Ask once" callout is now Linen; the footer line reads "The Corporate, Group Procurement and EHS and Sustainability"; the section labels no longer repeat the headings. Builder rows (S1 to S12 on the Deploy Preview) are still to run. S10 needs real fonts, so check it where Google Fonts loads. Verdict: ready for the builder's checks.
Reported by the builder on 16 November 2026: all builder checks (S1 to S12 on the Deploy Preview) done and passed before the merge on 9 November 2026; no per-row results were given to Claude Code. These are the v1.0 results; v2.0 rows start empty in docs/checks.md.
[Rule: the verifier's report per phase and per branch, with the date: one line per row, PASS or FAIL, and the builder's rows as performed. Kept, never cleared. A FAIL is fixed in the tool and re-run, never edited away.]

## Refusal test record
None yet. [Rule: filled by Claude Code at half A and by the builder at half B: date, who, cell tried, result. Kept, never cleared. Any change to a rule re-runs both halves before the push.]

## Build decisions
- Fonts load from Google Fonts only; in a blocked network the page falls back to Georgia and system sans.
- Header and nav are sticky on desktop and static on phones. Label and muted text use #6f6a5b (a darkened Stone) because Stone #B6B09F on Chalk fails AA contrast.
- Footer is Ink with Chalk text (no accent). The choice buttons show the chosen one as Ink fill.
- Governor decision: the deployed folder is site/, not the repo root, so docs/, reference/, fixtures/ and .claude/ are never served on the public URL.
- v2.0: the Backlog items for upload, storing submissions and completing the questionnaire in the page were promoted into Remaining work. Counting submissions and tracking who has responded stay on the Backlog as the dashboard.
- v2.0: Return by email was removed (submission is through the tool), which closes the open question on its subject line.
[Rule: one line per decision made during the build that is not in the spec. Future sessions depend on these to stay consistent.]

## Known issues
- Spec revised to v2.0 on 16 November 2026: CLAUDE.md and docs/checks.md regenerated by Project Governor.
- Before launch, not before build: the builder confirms whether Procurement or EHS and Sustainability signs off the page.
- Before launch: the privacy contact signs off the data notice, the lawful basis (contract or legitimate interest) and the retention "until deleted on request"; a fixed period may be required.
- Confirm that `https://ecovadis.com` is the right A Path link, or whether The Corporate has a customer-specific link or step for sharing a scorecard.
- Confirm the workbook is final for the 2027 cycle; its title and file name say 2026. The upload reader depends on its layout: if the workbook changes, update the reader's expected rows in the same change.
- Size limits: the matrix line 1 says `submit` refuses a body over 300 KB, but an upload carries the file (up to 4 MB). Applied as 300 KB for the form fields and 4 MB for the file, separately; confirm in the plan.
- Until the dashboard exists the builder reads submissions and opens files in the Supabase dashboard.
- The brand skill ships no logo files; draw the logo as inline SVG or CSS from the brand rules.
[Rule: bugs, edge cases, and deferred fixes. One line each. Remove when resolved.]

## Backlog
- Dashboard showing every submission, with its login, a reading role and a named first reader: a later change (v3.0); the database is built login-ready
- Supplier login and saved progress, including saving a half-finished form: Charter lists supplier accounts as out of scope
- Supplier editing or withdrawing a submission after confirming: a new submission replaces the old one
- Email notice to inbox@thecorporate.com for each submission, and any confirmation email: pending a sender (a sending domain or a company mailbox); the tool works without it
- Bot check (Cloudflare Turnstile): known risk, see the spec; add before sharing the link beyond testing
- Not in place: rate limit, queue, retry, virus scan, monitoring. What each would take: a rate limit needs a gateway or a database counter; a scan needs a scanning service on the upload path; monitoring needs a service watching the functions
- Automated supplier scoring, including an automatic PFAS flag; in-tool Scope 3 calculation; programmatic EcoVadis validation: Charter out of scope
- Languages other than English: validate the core page first
- Links to the Supplier Code of Conduct and Global Environmental Policy: no public URLs supplied yet; added by iteration
- Handover: Netlify and Supabase accounts are the builder's own; move them to company-owned accounts when the page is adopted; backups (Pro: Supabase daily; Free: none, the migration files and a data export are the rebuild path); alerts (Netlify Free: check Deploys after each push); where the keys live and how to rotate one; who supports the page and handles deletion requests; how to retire it
[Rule: deferred and approved items live here, nowhere else. When the spec is revised, review this list: an item now in scope is promoted into Remaining work and removed from here, with a Build decisions line saying so. Nothing here is built without being promoted.]

## Notes for next session
None.
[Rule: the builder writes here between sessions. Claude Code reads these aloud at session start, acts on them, then clears this section.]
