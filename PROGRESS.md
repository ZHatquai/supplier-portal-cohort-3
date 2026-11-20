# PROGRESS: Supplier Sustainability Portal

> Claude Code: read this file at the start of every session, before touching anything. Update it at every save point. Replace content, do not append. History lives in git.

**Session:** 2
**Last updated:** 16 November 2026
**Live URL:** https://supplier-portal-cohort-3.netlify.app/ [Rule: fill in after the first successful deploy]
**First deploy:** 9 November 2026 [Rule: the date the first pull request was merged with all builder checks passing; a record only]
**Stage:** business logic and database [Rule: one of business logic and database / second screen and access design / login and access rules together / deploy and maintain. Decided by what exists, never by a week or version. This tool has no database, so it stays on the first stage.]

## Plan for this session
Lane: fix (record-keeping only). Record the live address, first deploy date and the builder's completed checks in PROGRESS.md; no change to site/. Proves: no row of docs/checks.md is affected.

## Current state
The page is live at https://supplier-portal-cohort-3.netlify.app/, deployed from main after pull request 2 was merged on 9 November 2026. Site in site/ (index.html, css/styles.css, js/main.js, downloads/ with the workbook, byte-identical to reference/). All six blocks present: hero, 01 to 04, footer. Data checks D1 to D7 pass; the builder reports all builder checks done on the Deploy Preview. The build branch is merged and deleted. Claude Code could not load the live site from the cloud session (network policy), so the live load check is the builder's.
[Rule: describes what exists and works right now, never what is planned. Completed checklist items are absorbed here in compressed form.]

## Last session
Session 2 (16 November 2026): record-keeping only. The builder confirmed the deploy, the live address, the completed checks and the deleted branch; PROGRESS.md updated to match. No site changes.
[Rule: 3 to 5 lines maximum. Replace each session.]

## Remaining work
- [ ] Before launch (see Known issues): sign-off owner, A Path link, workbook final for the 2027 cycle, return email subject
[Rule: completed items leave this list and are absorbed into Current state. This list only shrinks.]

## Check results
9 November 2026, verifier, branch claude/keen-gates-p71k7k: D1 to D7 PASS; S1, S2, S4, S5, S10, S12 PASS; secrets clean; no protected files edited. Findings fixed after the report: the "Ask once" callout is now Linen; the footer line reads "The Corporate, Group Procurement and EHS and Sustainability"; the section labels no longer repeat the headings. Builder rows (S1 to S12 on the Deploy Preview) are still to run. S10 needs real fonts, so check it where Google Fonts loads. Verdict: ready for the builder's checks.
Reported by the builder on 16 November 2026: all builder checks (S1 to S12 on the Deploy Preview) done and passed before the merge on 9 November 2026; no per-row results were given to Claude Code.
[Rule: the verifier's report per phase and per branch, with the date: one line per row, PASS or FAIL, and the builder's rows as performed. Kept, never cleared. A FAIL is fixed in the tool and re-run, never edited away.]

## Build decisions
- Fonts load from Google Fonts only; in a blocked network the page falls back to Georgia and system sans.
- Header and nav are sticky on desktop and static on phones. Label and muted text use #6f6a5b (a darkened Stone) because Stone #B6B09F on Chalk fails AA contrast.
- Footer is Ink with Chalk text (no accent). The choice buttons show the chosen one as Ink fill.
- Governor decision: the deployed folder is site/, not the repo root, so docs/, reference/ and .claude/ are never served on the public URL.
[Rule: one line per decision made during the build that is not in the spec. Future sessions depend on these to stay consistent.]

## Known issues
- Before launch, not before build: the builder confirms whether Procurement or EHS and Sustainability signs off the page.
- Confirm that `https://ecovadis.com` is the right A Path link, or whether The Corporate has a customer-specific link or step for sharing a scorecard.
- Confirm the workbook is final for the 2027 cycle; its title and file name say 2026. The file can be swapped without changing the page.
- Final wording of the return email subject is open.
- The brand skill ships no logo files; draw the logo as inline SVG or CSS from the brand rules.
[Rule: bugs, edge cases, and deferred fixes. One line each. Remove when resolved.]

## Backlog
- Supplier login and saved progress: the Charter lists supplier accounts as out of scope this phase
- Upload of the completed questionnaire on the page: needs a server function and file storage; the B Path returns by email
- Storing or counting submissions, tracking who has responded: needs a database
- Completing the questionnaire inside the page: validate the core routing first
- In-tool Scope 3 calculation, automated supplier scoring, programmatic EcoVadis validation: Charter out of scope
- Languages other than English: validate the core page first
- Links to the Supplier Code of Conduct and Global Environmental Policy: no public URLs supplied yet; added by iteration
- Handover: Netlify account is the builder's own; move it to a company-owned account when the page is adopted; who supports the page; how to retire it; alerts (Netlify Free: check Deploys after each push)
[Rule: deferred and approved items live here, nowhere else. When the spec is revised, review this list: an item now in scope is promoted into Remaining work and removed from here, with a Build decisions line saying so. Nothing here is built without being promoted.]

## Notes for next session
- 20 November 2026: work is still ongoing on branch `claude/affectionate-ptolemy-udznhn` (pull request #4, not merged). It holds v2.0 (submission through the portal, Supabase) and the planned v2.1 changes from the builder's Deploy Preview test: a clearer A Path confirmation, number-only fields for Scope 1, 2, 3 and water withdrawal, and no stored Excel file. The live site on main is still v1.0. Continue that work on that branch, not from main. Once it is complete and pull request #4 is merged, delete the branch and delete this note.
[Rule: the builder writes here between sessions. Claude Code reads these aloud at session start, acts on them, then clears this section.]
