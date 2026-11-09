# PROGRESS: Supplier Sustainability Portal

> Claude Code: read this file at the start of every session, before touching anything. Update it at every save point. Replace content, do not append. History lives in git.

**Session:** 0, build not started
**Last updated:** 9 November 2026, by Project Governor, pre-build
**Live URL:** none yet [Rule: fill in after the first successful deploy]
**First deploy:** not yet [Rule: the date the first pull request was merged with all builder checks passing; a record only]
**Stage:** business logic and database [Rule: one of business logic and database / second screen and access design / login and access rules together / deploy and maintain. Decided by what exists, never by a week or version. This tool has no database, so it stays on the first stage.]

## Plan for this session
None yet. [Rule: Claude Code opens in plan mode, states the lane (fix / change), proposes the plan, and writes the approved plan here (3 to 8 lines). Replaced each session. A change whose spec version has not moved goes to the Tool Architect, not here.]

## Current state
Nothing built. Repo contains CLAUDE.md, PROGRESS.md, product-spec.md, intent.md, checks.md, .claude/settings.json, the-corporate-brand.md (brand skill, installed in session 1) and reference/ (the questionnaire workbook).
[Rule: describes what exists and works right now, never what is planned. Completed checklist items are absorbed here in compressed form.]

## Last session
None. The first build session has not happened yet.
[Rule: 3 to 5 lines maximum. Replace each session.]

## Remaining work
- [ ] First Session Setup: create docs/, move the spec, intent.md and checks.md into it and check each is there, install The Corporate brand skill, write netlify.toml (publish = "site"), commit (see CLAUDE.md Session Protocol)
- [ ] Build Header and hero, with the lime deadline badge and Start button, in site/index.html, css/ and js/, then copy the workbook into site/downloads/ unchanged, then run its rows in docs/checks.md and the verifier
- [ ] Build 01 Overview: four figures and six themes, then run its rows in docs/checks.md and the verifier
- [ ] Build 02 Why we are contacting you: three cards and the "Ask once" callout, then run its rows in docs/checks.md and the verifier
- [ ] Build 03 How this works: two route cards and the four-phase 2027 timeline, then run its rows in docs/checks.md and the verifier
- [ ] Build 04 What you can do: the question, the A Path and the B Path with its download and email links, then run its rows in docs/checks.md and the verifier
- [ ] Build Footer: contact and the standing privacy line, then run its rows in docs/checks.md and the verifier
- [ ] Checks pass for this stage: every row in docs/checks.md shows a pass dated today; the verifier's report pasted under Check results
- [ ] First build, before the pull request: the builder connects the repo to a Netlify site (Add new project, Import an existing project, GitHub, this repo; Branch to deploy: main)
- [ ] Push the branch and confirm it reached GitHub; open the pull request (or give the builder the prefilled compare link) and give the builder its link
- [ ] Builder checks: on request, the builder rows of docs/checks.md as a numbered list of actions; record the results; fix failures in this session
- [ ] Builder: merge the pull request and delete the branch, then main deploys. Claude Code never merges. The builder sends the site address; Claude Code checks the live site and records it as Live URL next session. This session is then done.
[Rule: completed items leave this list and are absorbed into Current state. This list only shrinks.]

## Check results
None yet. [Rule: the verifier's report per phase and per branch, with the date: one line per row, PASS or FAIL, and the builder's rows as performed. Kept, never cleared. A FAIL is fixed in the tool and re-run, never edited away.]

## Build decisions
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
