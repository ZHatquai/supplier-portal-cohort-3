# PROGRESS: Supplier Sustainability Portal

> Claude Code: read this file at the start of every session, before touching anything. Update it at every save point. Replace content, do not append. History lives in git.

**Session:** 1
**Last updated:** 9 November 2026
**Live URL:** none yet [Rule: fill in after the first successful deploy]
**First deploy:** not yet [Rule: the date the first pull request was merged with all builder checks passing; a record only]
**Stage:** business logic and database [Rule: one of business logic and database / second screen and access design / login and access rules together / deploy and maintain. Decided by what exists, never by a week or version. This tool has no database, so it stays on the first stage.]

## Plan for this session
(Approved 9 November 2026.) Lane: first build. 1) First Session Setup (done). 2) Build site/index.html, css/, js/ section by section: hero, 01, 02, 03, 04, footer. 3) Run docs/checks.md data and screen rows (headless Chromium, desktop and 360px), then the verifier. 4) Push, open the pull request, builder connects Netlify, builder checks on the Deploy Preview, builder merges. Risks: lime exactly twice, A Path new tab, workbook byte-identical, no internal-only terms.

## Current state
Page built in site/ (index.html, css/styles.css, js/main.js, downloads/ with the workbook, byte-identical to reference/). All six blocks present: hero, 01 to 04, footer. netlify.toml publishes site/ and forces the download. Data checks D1 to D7 pass. Screen behaviour verified in headless Chromium at 1280px and 360px. Not yet deployed.
[Rule: describes what exists and works right now, never what is planned. Completed checklist items are absorbed here in compressed form.]

## Last session
Session 1 (9 November 2026): ran First Session Setup, built the whole page, ran data checks and a browser pass of the screen checks. Open: verifier run, then pull request.
[Rule: 3 to 5 lines maximum. Replace each session.]

## Remaining work
- [ ] First build, before the pull request: the builder connects the repo to a Netlify site (Add new project, Import an existing project, GitHub, this repo; Branch to deploy: main)
- [ ] Push the branch and confirm it reached GitHub; open the pull request (or give the builder the prefilled compare link) and give the builder its link
- [ ] Builder checks: on request, the builder rows of docs/checks.md as a numbered list of actions; record the results; fix failures in this session
- [ ] Builder: merge the pull request and delete the branch, then main deploys. Claude Code never merges. The builder sends the site address; Claude Code checks the live site and records it as Live URL next session. This session is then done.
[Rule: completed items leave this list and are absorbed into Current state. This list only shrinks.]

## Check results
9 November 2026, verifier, branch claude/keen-gates-p71k7k: D1 to D7 PASS; S1, S2, S4, S5, S10, S12 PASS; secrets clean; no protected files edited. Findings fixed after the report: the "Ask once" callout is now Linen; the footer line reads "The Corporate, Group Procurement and EHS and Sustainability"; the section labels no longer repeat the headings. Builder rows (S1 to S12 on the Deploy Preview) are still to run. S10 needs real fonts, so check it where Google Fonts loads. Verdict: ready for the builder's checks.
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
None.
[Rule: the builder writes here between sessions. Claude Code reads these aloud at session start, acts on them, then clears this section.]
