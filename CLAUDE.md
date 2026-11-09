# Supplier Sustainability Portal

## Identity
A single public web page that explains The Corporate's supply chain sustainability programme to Tier 1 suppliers and routes each one to EcoVadis (A Path) or the questionnaire (B Path). Anyone with the link can use it.
Tier: 1, a public page, no database, no login, nothing stored (D1+A1)
Spec version governed: v1.0 (docs/product-spec.md)
Position: Standalone

## Session Protocol
You open in plan mode (.claude/settings.json). You read and propose; you change nothing until the builder approves the plan.

At the start of every session:
1. Pull the latest from main first.
2. Never work on main, never push to main, never merge. In a cloud session work on the branch the session is on (`claude/...`); locally create one named for the intent. Every session ends with a pull request the builder merges.
3. If docs/product-spec.md is newer than "Spec version governed" above, STOP: "The spec has changed since this CLAUDE.md was written. Re-run the Project Governor on the revised spec before building."
4. Read PROGRESS.md (recreate it with the structure below if missing) and docs/checks.md, which defines "done".
5. Increment the session number and date in PROGRESS.md. Read any "Notes for next session" aloud, treat them as priorities, then clear them.
6. Plan first. State the lane: **fix** (the tool is not yet what the spec says) or **change** (the tool would become something the spec does not say: a login, stored submissions, an upload, a new screen or connection). A change needs its own session: tell the builder to start a new session and describe it in their own words, and offer to add it to the Backlog. Otherwise propose the plan (what changes, in what order, which rows of docs/checks.md prove it, what could break), wait for approval, write it into PROGRESS.md "Plan for this session", then build.
7. Session 1 only: run First Session Setup below before any build work.

Save point, after any module, feature or fix:
1. Update PROGRESS.md (state, remaining work, decisions, known issues).
2. Commit and push the branch, then confirm it reached GitHub (`git ls-remote origin <branch>` shows your commit). Never report a push you have not confirmed.
3. Tell the builder in one line: "Save point pushed: [what changed]." Do not start the next piece before this. An ending session is a save point.

Done means the checks pass. At the end of every phase: run every row of docs/checks.md you can perform and write the result and date in Last result (fix the tool, never the row); run the verifier agent and paste its report under "Check results" in PROGRESS.md; report the phase done only when both pass.

End of the session, one pull request:
1. If **Live URL:** is none yet, tell the builder before the pull request: "Next: connect Netlify once. Add new project, Import an existing project, GitHub, this repo. Check Branch to deploy says main. Keep the settings (netlify.toml sets them). Tell me when it is connected."
2. Push the branch and confirm it. Open the pull request (tool, `gh pr create`, or the prefilled link https://github.com/ZHatquai/supplier-portal-cohort-3/compare/main...[branch]?expand=1) and give the builder its link: Netlify builds a Deploy Preview on it.
3. Tell the builder: "Open the Deploy Preview, then say *checks* and I'll give you the list." On request give every builder row of docs/checks.md as one numbered list of actions (what to open or do, what they should see). Record results in docs/checks.md and PROGRESS.md; fix failures in this session. A decision for the builder is its own question, never inside the list.
4. When the rows pass: record **First deploy:** if it reads "not yet" and say "All checks pass. Merge the pull request and delete the branch; the live site updates. Then send me the site address." You never merge.
5. After the merge, check the live site loads, say the address goes into PROGRESS.md next session, then: "This session is done. For the next idea or change, start a new session."

First Session Setup (session 1 only):
1. Create docs/ and move product-spec.md, intent.md and checks.md into it. Keep .claude/settings.json and reference/ where they are. Check each file is where it should be; stop with a plain message if one is missing ("I cannot find [file]; add it to the repo root and I will move it").
2. Write netlify.toml: `[build]` with `publish = "site"` and no command. The site lives in site/ so docs/, reference/ and .claude/ are never served.
3. Install the brand skill: create .claude/skills/the-corporate-brand/ and move the-corporate-brand.md (repo root) there as SKILL.md (it already has name/description frontmatter).
4. Announce what moved, commit and push the branch before building.

PROGRESS.md structure: status header (Session, Last updated, Live URL, First deploy, Stage), Plan for this session, Current state, Last session, Remaining work, Check results, Build decisions, Known issues, Backlog, Notes for next session.

## Commands
```
npx serve site
```

## Tech Stack
HTML · CSS · JavaScript (no framework, no build step) · Netlify
Deployment: GitHub push, Netlify auto-deploys. You work on a branch and push it; the builder opens the pull request, checks the Netlify Deploy Preview against docs/checks.md, merges on GitHub and deletes the branch; main deploys. You never connect to Netlify; no Netlify connector or MCP is used. The builder connects the repo to a Netlify site once, in the Netlify dashboard.

## Hard Rules
- No API key, token or credential in any file. This tool needs none.
- No form, no tracking, no cookies, no analytics, no database call, no script beyond the page's own. The only external resource is the Google Fonts stylesheet. The footer says: "This page does not collect or store any information about you."
- Complexity: build no rate limit, queue, retry, scan, monitor or test framework. If a request asks for one, put it on the Backlog as "not in place; what it would take" and tell the builder.
- Done means the checks pass: no phase is done and no branch is handed over until its rows in docs/checks.md pass and the verifier agrees. Never edit docs/checks.md to make a check pass.
- Branch rule: never push to main, never merge. One branch, pushed and confirmed, one pull request per session. One intent per session.
- Never copy text from docs/ or reference/ that the spec's Section 8 does not list for the page. The Charter and Strategy are confidential; the page uses only what Section 8 states.

## Things Claude gets wrong
Read this before every save point. When the builder corrects the same mistake a second time, add it here as one line, in that session, before anything else.
- Writing a key value into a file or a command.
- Adding a figure, role or rule from the confidential Charter or Strategy that Section 8 does not list (for example the 690,000 tCO₂e total, RACI roles, the 15-business-day triage rule, "escalated").
- Reporting a phase done without running its rows in docs/checks.md and the verifier.

## Project Structure
Root: CLAUDE.md, PROGRESS.md, netlify.toml · site/ (deployed: index.html, css/, js/, assets/, downloads/) · docs/ (intent.md, product-spec.md, checks.md) · reference/ (workbook, never edited) · .claude/ (settings.json, skills/the-corporate-brand/)

## Brand
Brand is governed by The Corporate brand skill at .claude/skills/the-corporate-brand/SKILL.md (installed in First Session Setup). Invoke it before any UI or copy work. Hard rules that hold even if it is not loaded:
- Background: Chalk #F2F2F2; surfaces Linen #EAE4D5 and White; text Ink #000000; muted Stone #B6B09F
- Accent: Acid Lime #C8F135, only against Ink, exactly twice on the page (the deadline badge, the question panel's 2px left border). Never Tailwind blue defaults.
- Fonts: Playfair Display for headlines, DM Sans (300 body) for all other text, from Google Fonts
- Square corners, 0.5px hairline borders, no shadows, no gradients, no emoji, no exclamation points, no em dashes in prose, dates as DD Month YYYY
- No logo files exist in the repo: draw the logo (black square with "C", wordmark THE CORPORATE in DM Sans Light, 0.12em tracking) as inline SVG or CSS.

## Business Rules
- The question "Do you have an EcoVadis Scorecard?" starts section 04 with neither path visible. Yes shows the A Path, No shows the B Path, switching replaces the visible path, nothing is stored, and a reload returns to the neutral state.
- A Path button: `https://ecovadis.com`, `target="_blank"`, `rel="noopener noreferrer"`. It is not an automatic redirect.
- B Path: the workbook is served unchanged from reference/The_Corporate_Supplier_Questionnaire_2026_39.xlsx at /downloads/The_Corporate_Supplier_Questionnaire_2026.xlsx (copy it into site/downloads/, forced download). "Return by email" is a `mailto:inbox@thecorporate.com` link with the subject "Supplier Sustainability Assessment 2026: [Company name]"; the address is also printed as text.
- Cycle dates are the 2027 cycle: April 2027, 30 September 2027, Q4 2027, Q1 2028. No 2026 date appears. Named documents keep their 2026 titles.
- Figures on the page are only 71%, 500+, 2045 and 50% (by 2030 against 2023). No tCO₂e totals, internal roles or escalation rules.
- English only. Every control works by keyboard; the page works from 360px wide with no horizontal scroll.

Out of scope, do not build:
- Supplier login and saved progress; storing or counting submissions; tracking who has responded
- Upload of the completed questionnaire on the page; completing the questionnaire inside the page
- In-tool Scope 3 calculation, automated supplier scoring, programmatic EcoVadis validation
- Languages other than English; links to the Supplier Code of Conduct and Global Environmental Policy (no URLs yet)

## Reference Docs
Read before building the related part:
- docs/intent.md: why the tool exists, in the originator's words
- docs/product-spec.md: every view, the copy points, the checks, the open questions
- docs/checks.md: what done means; run its rows, never edit them
- .claude/skills/the-corporate-brand/SKILL.md: the full brand system
PROGRESS.md in the root is read at every session start.
