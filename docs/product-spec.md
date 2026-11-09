# Product Spec: Supplier Sustainability Portal

**Version:** 1.0
**Date:** 9 November 2026
**Author:** Zyad Hatquai
**Status:** Confirmed
> Set to Confirmed by the Tool Architect when the builder confirmed the Phase 10 summary. The Project Governor accepts only this status.

---

## Section 1: Tool Summary

**Tool name:** Supplier Sustainability Portal

**What it does:** A single public web page that explains The Corporate's supply chain sustainability programme to its Tier 1 suppliers and routes each supplier to one of two actions. A supplier with an EcoVadis scorecard goes to EcoVadis (A Path). A supplier without one downloads The Corporate's questionnaire and returns it by email (B Path).

**Who uses it:** Procurement contacts at The Corporate's 500+ Tier 1 suppliers, across all sourcing categories. They arrive from one link, issued through the Procurement Portal and reinforced by account manager outreach.

**Why it exists:** The Corporate reports value-chain sustainability performance under CSRD from the 2026 reporting cycle, and about 71% of its footprint sits with suppliers. Long manual surveys produce low response rates. This page gives every supplier one clear route: ask once, and do not make suppliers with a recognised third-party rating repeat the work (the Smart Intake rule).

**Build status:** First build, no prior version. Source documents: Supplier Engagement Programme 2026 Program Charter v1.0, Procurement Sustainability Strategy 2026 v1.0, and the Supplier Sustainability Assessment 2026 workbook. The programme documents are named "2026". This page runs the **2027 cycle**: all Charter dates are carried forward by one year (builder decision, 9 November 2026).

---

## Section 2: Classification

### Data Model

**Decision:** D1

| Label | What it means | This tool? |
|-------|--------------|-----------|
| D1 Hardcoded | All data is written into the code by the developer. | **Yes** |
| D2 Session | Data enters during use and disappears when the tab closes. | No |
| D3 Persisted | Data is written to a database. Supabase required. | No |

**Reason:** All content is written in by the builder. The only user interaction is a Yes or No choice that changes what is shown and is never stored. The Charter states the portal retains no database at launch.

**D3 triggers (none apply):**
- [ ] Data must be retrievable after the session ends
- [ ] Multiple sessions contribute to the same dataset
- [ ] An audit trail or history is needed
- [ ] Data submitted by one person must be visible to another
- [ ] Results must be accessible via a URL after the session ends
- [ ] Files uploaded by users must be stored and retrievable later

### Access Model

**Decision:** A1

| Label | What it means | This tool? |
|-------|--------------|-----------|
| A1 Public | Anyone with the URL can use it. No login. | **Yes** |
| A2 Authentication | Users must log in, same rights for all. | No |
| A3 Authorization | Users must log in and have different roles. | No |

**Reason:** The page is one link sent to 500+ suppliers. A login would add friction and the Charter lists supplier accounts as out of scope.

### Tier

**Tier:** 1 (D1 + A1, Netlify only, no database, no login)

### Standalone or Stack

**This tool is:** Standalone. It shares no database with any other tool.

---

## Section 3: Arms

No arm is active.

### AI API Arm
**Active:** No

### Export Arm
**Active:** No. The questionnaire is a static file the builder places in the site. It is not generated from data, so it is not an Export arm.

### Email Arm
**Active:** No. The "Return by email" button is a standard `mailto:` link that opens the supplier's own mail program. The tool sends nothing. The supplier attaches the file themselves.

### Scheduled Automation Arm
**Active:** No

> Natural-language search over documents is outside this framework and is not part of this tool.

---

## Section 4: Stack and Deployment

### All Tiers

| Detail | Answer |
|--------|--------|
| Frontend framework | HTML/CSS/JS. One view and one toggle, so no framework is needed. Single `index.html` with linked CSS and JS, no build step required. |
| Deployment target | Netlify |
| Deployment | GitHub push, then Netlify auto-deploy. Always a branch, one per session (one intent). Claude Code works on the session's branch and pushes it; it never pushes to main or merges. The session ends with a pull request the builder opens on GitHub (Compare and pull request). Netlify builds a Deploy Preview of it, the builder runs the builder rows of `docs/checks.md` there, merges on GitHub and deletes the branch, and main deploys. On the first build the builder connects the repo to a Netlify site once, when the first pull request is open (branch to deploy: main, no build command, publish directory as set by Claude Code). Netlify is not connected to Claude: no Netlify connector or MCP is used. |
| Supabase and Netlify connection | Not applicable. Tier 1, no Supabase. |
| Platform owner | The builder, on their own Netlify account. (Builder decision default, change if the page moves to a company account.) |

**GitHub:** the repo `ZHatquai/supplier-portal-cohort-3` exists. The Tool Architect and the Project Governor write their files at the repo root; Claude Code moves them into `docs/` in its first build session.

### Supabase project
Not applicable. Tier 1.

### Stack
Not applicable. Standalone.

---

## Section 5: Data Architecture

Not applicable. Data model is D1.

**Static assets:**

| Asset | Source in repo | Served at | Note |
|-------|---------------|-----------|------|
| Supplier questionnaire workbook | `reference/The_Corporate_Supplier_Questionnaire_2026_39.xlsx` (supplied by the builder) | `/downloads/The_Corporate_Supplier_Questionnaire_2026.xlsx` | Copied byte for byte, never edited by Claude Code. Served with a download header so it saves rather than opens. |
| The Corporate logo | Brand skill, `assets/logo/tc-logo-primary.svg` and `tc-monogram.svg` | `/assets/` | Monogram also used as the favicon. |

> The two Charter and Strategy PDFs are confidential, internal documents. They are not committed to the repo. Everything the page needs from them is stated in Section 8.

---

## Section 6: Access and Permissions

Not applicable. Access model is A1: no login, no roles, no accounts.

---

## Section 7: GDPR

**GDPR outcome:** Not applicable. Confirmed in the interview: the tool has no forms, stores nothing, runs no database, and collects no personal data. The "Return by email" link only opens the supplier's own mail program. The questionnaire the supplier returns contains a contact name, title and email, which reaches The Corporate's own mailbox by the supplier's own email, outside this tool. The Corporate's existing supplier privacy notice covers that mailbox.

**Personal data the tool holds:** None.

**Standing line for the page footer** (Section 8): "This page does not collect or store any information about you."

---

## Section 8: Screen and UI Structure

One page, one URL, five stacked blocks plus header and footer. English only. Anchor links in the header jump to each numbered section. All copy follows the voice rules in Section 10.

### Header and hero

- **Purpose:** Identify the page and state the one thing a supplier must know first: the deadline.
- **What is visible:**
  - The Corporate logo lockup (black box with "C" and the wordmark THE CORPORATE).
  - Anchor links: 01 Overview, 02 Why you, 03 How it works, 04 Your action.
  - Eyebrow label: SUPPLIER ENGAGEMENT PROGRAMME, 2027 CYCLE.
  - H1: "Supplier Sustainability Portal".
  - Intro line: one sentence stating the page is for Tier 1 suppliers and the action takes one of two routes.
  - **Deadline badge (Acid Lime use 1 of 2):** black container, lime uppercase text: "Submissions close 30 September 2027".
  - Button: "Start" that scrolls to section 04.
- **User actions:** scroll, use anchors, press Start.
- **What happens next:** the page scrolls to the chosen section.

### 01 Overview: supply chain sustainability at The Corporate

- **Purpose:** Give suppliers the context of the Corporate's supply chain sustainability programme.
- **What is visible:**
  - H2 and two short paragraphs: The Corporate is committed to net-zero across the full value chain by 2045. Most of its footprint is created in its supply chain, so supplier performance decides whether the commitment is met.
  - Four figures in a four-column grid (one column on phones), each with a large numeral and a caption:
    - **71%** of The Corporate's carbon footprint sits in the value chain (Scope 3).
    - **500+** Tier 1 suppliers in the programme.
    - **2045** net-zero target across the full value chain.
    - **50%** emissions reduction by 2030 against the 2023 base year.
  - Six priority themes as a bordered list, each with its ESRS reference: Climate and value-chain emissions (E1); Pollution and substances of concern (E2); Water (E3); Circular economy and critical raw materials (E5); Human and labour rights (S2); Business conduct (G1).
  - One sentence: the programme implements The Corporate's Global Environmental Policy and is made binding on suppliers through the Supplier Code of Conduct. No link is built unless the builder supplies one (Section 15).
- **User actions:** read.
- **What happens next:** scroll to 02.

### 02 Why we are contacting you

- **Purpose:** Explain to the supplier why they received the link and what is expected of them, in plain terms.
- **What is visible:**
  - H2 and a short lead: "You are a Tier 1 supplier to The Corporate. This is why that matters now."
  - Three bordered cards:
    1. **We must report what we cannot yet see.** Under the EU Corporate Sustainability Reporting Directive (CSRD), The Corporate reports value-chain performance from the 2026 reporting cycle. Supplier data is the evidence.
    2. **Suppliers are the largest lever.** Reducing emissions in the supply chain is the single biggest action available to The Corporate on its net-zero path.
    3. **Due diligence is now a legal expectation.** Risk-based supply chain due diligence follows the German Supply Chain Act (LkSG) and the EU Corporate Sustainability Due Diligence Directive (CSDDD).
  - A Linen callout headed "Ask once": suppliers with a recognised third-party rating are not asked to repeat the work. Everyone else completes one structured assessment. It is the start of a working relationship, and strong performers earn preferential standing.
- **User actions:** read.
- **What happens next:** scroll to 03.

### 03 How this works

- **Purpose:** Show the two routes and the timeline before the supplier chooses.
- **What is visible:**
  - H2 and one sentence: one portal, one assessment, two routes.
  - Two cards side by side:
    - **Route A, EcoVadis.** Hold a valid EcoVadis scorecard? Submit it and you are exempt from the detailed assessment. Validations are processed weekly.
    - **Route B, Full assessment.** No current scorecard? Complete The Corporate's sustainability assessment across the priority themes and return it by email.
  - **Timeline**, four phases in a horizontal row (stacked on phones), each with a number, stage, date and one line:

    | Phase | Stage | When | Focus |
    |-------|-------|------|-------|
    | 01 | Portal launch | April 2027 | The portal opens to 500+ Tier 1 suppliers. Both routes are open. |
    | 02 | Data submission | Deadline 30 September 2027 | Target: 100% Tier 1 response. EcoVadis scorecards are validated on a rolling basis. |
    | 03 | Review and scoring | Q4 2027 | The Corporate reviews submissions and flags gaps. |
    | 04 | Partnership plans | Q1 2028 | Joint improvement plans with prioritised suppliers. |

  - Phase 02 is marked as the current action phase with a solid Ink top border. No lime here.
- **User actions:** read.
- **What happens next:** scroll to 04.

### 04 What you can do

- **Purpose:** Let the supplier choose the route and take the action.
- **What is visible at first load:**
  - H2: "What you can do".
  - **The question panel (Acid Lime use 2 of 2, Pattern B, 2px lime left border):** H3 "Do you have an EcoVadis Scorecard?" with a small helper line: "A valid scorecard is one issued within the last 12 months."
  - Two equal buttons side by side: "Yes, I have one" and "No, I do not". Neither is preselected. Both are real buttons, reachable by keyboard, and expose their state to screen readers (`aria-pressed`, and the paths use `aria-expanded` with `aria-controls`).
  - Both paths are closed.
- **A Path (opens when Yes is chosen):**
  - Heading "Route A: submit your EcoVadis scorecard".
  - Three numbered steps: 1. Confirm your scorecard was issued within the last 12 months. 2. Open EcoVadis and share your scorecard with The Corporate. 3. You are finished: you are exempt from the detailed assessment and do not complete the questionnaire.
  - One line: "The Corporate validates EcoVadis submissions weekly."
  - Primary button "Go to EcoVadis" linking to `https://ecovadis.com`, opens in a new tab with `rel="noopener noreferrer"`. Not an automatic redirect, so the supplier reads the steps first.
  - A text link "I do not have one" that switches to the B Path.
- **B Path (opens when No is chosen):**
  - Heading "Route B: complete the questionnaire".
  - A bordered preview list of the workbook sections: S1 General information and EcoVadis question; S2 Climate and decarbonisation (E1); S3 Pollution and PFAS (E2); S4 Water and marine resources (E3); S5 Circular economy and waste (E5); S6 Biodiversity and ecosystems (E4); S7 Social, labour and governance (S2, G1).
  - Four numbered steps: 1. Download the questionnaire (Excel). 2. Complete every section marked Required, S1 to S7, and sign the declaration at the end. 3. Save the file under your company name. 4. Return it by email.
  - Primary button "Download questionnaire (.xlsx)" with the file name and a "Microsoft Excel" label.
  - Secondary button "Return by email" is a `mailto:` link to `inbox@thecorporate.com` with a prefilled subject "Supplier Sustainability Assessment 2026: [Company name]" and a body line asking the supplier to attach the completed workbook. The mailbox address is also printed in plain text next to the button so it can be copied.
  - A text link "I have a scorecard after all" that switches to the A Path.
  - A note: PFAS answers are reviewed by The Corporate's EHS team. (No SLA is stated.)
- **User actions:** choose Yes or No (switchable at any time), follow the A Path button, download the workbook, press the email link.
- **What happens next:** the supplier leaves for EcoVadis (A), or downloads and emails the file (B). The page stores nothing about which route was chosen.

### Footer

- **Purpose:** Contact and the standing privacy line.
- **What is visible:** logo, "Questions about this programme? inbox@thecorporate.com", the standing line from Section 7, "The Corporate, Group Procurement and EHS and Sustainability", and the "2027 cycle" label.
- **No "About this tool" view:** it is required only for D3 tools. The footer carries the contact and the privacy line instead.

### Responsive and accessibility behaviour (applies to every view)

- Works from 360px wide: grids collapse to one column below 768px, 16px side padding, no horizontal scroll.
- Colour contrast meets WCAG AA. Lime is used only on Ink.
- Visible keyboard focus on every control.
- Opening a path moves focus to its heading. The page honours `prefers-reduced-motion` (no animation is required).
- The page works without a network call after it has loaded. Only the two outbound links (EcoVadis, email) and the download touch the outside.

---

## Section 9: Logic and Calculations

Not applicable, apart from this display rule:

**Rule:** the question panel controls which path is visible. Yes shows the A Path and hides the B Path. No shows the B Path and hides the A Path. Switching replaces the visible path. Before any choice, neither path is visible. The choice is held in memory for the visit only and is not stored anywhere. A reload returns to the neutral state.

---

## Section 10: Brand and Visual Direction

**Brand reference:** the `the-corporate-brand` skill (The Corporate brand specification). Claude Code reads it before writing any page code and copy. If the skill file is not in the repo, the builder adds it at the repo root, and Claude Code installs it to `.claude/skills/` in the first session.

**Visual feel:** Professional and corporate. Corporate minimalism, restraint over decoration.

**Rules lifted from the brand skill that the build must follow:**
- Colours: Ink `#000000`, Stone `#B6B09F`, Linen `#EAE4D5`, Chalk `#F2F2F2` (page background), White, and Acid Lime `#C8F135` used **twice at most per page** and only against Ink. The two uses are the deadline badge (Section 8, hero) and the question panel (Section 8, section 04).
- Fonts: Playfair Display for headlines (H1 700, H2 400), DM Sans for everything else (body 300 at 15px, line-height 1.75), loaded from Google Fonts.
- Square corners everywhere. Hairline 0.5px borders. No shadows, no gradients, no decorative fills.
- Buttons: primary Ink fill with Chalk text, secondary transparent with an Ink hairline border, uppercase with 0.1em tracking.
- Logo: black square box with the "C", wordmark in DM Sans Light, tracked 0.12em. Never recoloured.
- Max page width 1120px, body text column 720px.
- Copy: short declarative sentences, active voice, no exclamation points, no emoji, no vague qualifiers, dates as DD Month YYYY, Oxford comma, numerals for data. No em dashes in running prose.

**Reference or inspiration:** the look of the Charter and Strategy PDFs: numbered section labels (01 to 04), tracked uppercase eyebrow labels, hairline tables, large figure numerals.

---

## Section 11: API and Credentials

| Service | What it does in this tool | Key required | Where key is stored |
|---------|--------------------------|-------------|-------------------|
| None | The tool has no server, no database and no third-party API. | None | Not applicable |

- Outbound links only: `https://ecovadis.com` and `mailto:inbox@thecorporate.com`.
- Google Fonts (a stylesheet link) is the only external resource loaded.

**Environment variable contract:** none. The tool reads no environment variables.

**Credentials readiness:** nothing to create.

> **Security rule, no exceptions:** no API key, token, password or credential may appear in any file committed to GitHub. The tool needs none.

---

## Section 12: Out of Scope, Phase 2

| Deferred feature | Reason it is deferred |
|-----------------|----------------------|
| Supplier login and saved progress | Charter lists supplier accounts as out of scope this phase |
| Upload of the completed questionnaire on the page | Needs a server function and file storage; Charter launch scope keeps no database. The B Path returns by email. |
| Storing or counting submissions, tracking who has responded | Requires a database (D3) |
| Completing the questionnaire inside the page | Validate the core routing first |
| In-tool Scope 3 calculation | Charter out of scope |
| Automated supplier scoring | Charter out of scope |
| Programmatic EcoVadis validation | Charter out of scope |
| Languages other than English | Validate the core page first |
| Link to the Supplier Code of Conduct and Global Environmental Policy | No public URLs supplied yet; added by iteration when available |

---

## Section 13: Acceptance Criteria (the checks)

The Project Governor writes this section out as `docs/checks.md`. A failing check is fixed in the tool, never in the check.

**Data checks**

| # | Given (fixture or action) | Expected result | Performed by |
|---|---------------------------|-----------------|--------------|
| D1 | The built site's `/downloads/` file compared with `reference/The_Corporate_Supplier_Questionnaire_2026_39.xlsx` | Identical bytes (checksum match). The file opens and its sheet "Supplier Assessment 2026" has 7 sections, S1 to S7. | Claude Code, verifier |
| D2 | The "Return by email" link in the built HTML | `href` starts with `mailto:inbox@thecorporate.com`, contains a subject, and has no other recipient | Claude Code, verifier |
| D3 | The "Go to EcoVadis" link in the built HTML | `href` is `https://ecovadis.com`, `target="_blank"`, `rel` contains `noopener` | Claude Code, verifier |
| D4 | Search the built output and the repo for `ecovadis`, `inbox@`, `api_key`, `secret`, `token`, `eyJ`, and for the strings `690,000`, `RACI`, `15 business days`, `escalat` | The two intended links appear. No credential string appears. None of the four internal-only terms appears in any page text. | Claude Code, verifier |
| D5 | Timeline text | Shows April 2027, 30 September 2027, Q4 2027 and Q1 2028, and no 2026 date | Claude Code, verifier |
| D6 | The four figures | 71%, 500+, 2045 and 50% appear, and no other tCO2e figure appears | Claude Code, verifier |

**Screen checks**

| # | Screen | What must be true | Performed by |
|---|--------|-------------------|--------------|
| S1 | Hero | Logo, title, "Submissions close 30 September 2027" lime badge on black, and a Start button that scrolls to section 04 | builder, verifier |
| S2 | 01 Overview | Four figures and six themes with ESRS references; figures stack to one column on a phone | builder, verifier |
| S3 | 02 Why | Three cards and the "Ask once" callout | builder |
| S4 | 03 How it works | Two route cards and the four-phase timeline with the right dates | builder, verifier |
| S5 | 04 before any choice | The question and both buttons are visible, and neither path is visible | builder, verifier |
| S6 | 04, press Yes | A Path opens, B Path stays hidden, "Go to EcoVadis" opens EcoVadis in a new tab | builder |
| S7 | 04, press No | B Path opens, A Path hidden, the file downloads and opens in Excel, the email button opens a draft to inbox@thecorporate.com with the subject filled | builder |
| S8 | 04, switch routes | Pressing Yes then No (and back) shows only the latest path each time; a reload returns to the neutral state | builder |
| S9 | Footer | Contact address and the line "This page does not collect or store any information about you." | builder |
| S10 | Brand | Acid Lime appears exactly twice and only on Ink or as the 2px left border; square corners; no shadows or gradients; Playfair headlines and DM Sans body | builder, verifier |
| S11 | Phone (360px) | No horizontal scroll; the timeline stacks; buttons are at least 44px tall | builder |
| S12 | Keyboard | Every control is reachable with Tab, shows a focus ring, and the question buttons work with Enter and Space | builder, verifier |

**Refusal checks:** none. There is no login, no role and no database, so no matrix exists for this tool.

---

## Section 14: Build Path

**This tool's tier:** Tier 1

### Pre-build steps

- [x] GitHub repo created by the builder and open in Claude Code
- [x] The idea saved in the builder's words as `intent.md`
- [x] Tool Architect: interview complete, this spec written to the repo root and confirmed
- [ ] Project Governor: CLAUDE.md, PROGRESS.md, checks.md and `.claude/settings.json` written to the repo from this spec
- [ ] Brand skill (`the-corporate-brand`) available to Claude Code in the repo
- [ ] Type Start in the same session

No Access Architect run is needed: there is no database.

### Tier 1: build session

- [ ] First Session Setup: Claude Code creates `docs/`, moves the reference files, installs the brand skill, all on the session's branch
- [ ] Claude Code reads product-spec.md, CLAUDE.md, PROGRESS.md and docs/checks.md and proposes the plan; the builder approves
- [ ] Claude Code builds the page, runs data and screen checks it can, pastes results into PROGRESS.md, runs the verifier
- [ ] The builder connects the repo to a Netlify site (branch to deploy: main) when the first pull request is open
- [ ] Claude Code pushes the branch and opens the pull request or gives the compare link
- [ ] The builder says *checks*; Claude Code lists the builder rows as numbered actions; the builder replies with failed numbers or "all pass"
- [ ] The builder merges and deletes the branch, then main deploys; the builder sends the site address and Claude Code checks the live site

---

## Section 15: Open Questions

| Question | Who answers it | Blocking? |
|----------|---------------|-----------|
| Does Procurement or EHS and Sustainability sign off the page before it goes to suppliers? | Builder | Yes, before launch (not before build) |
| Is `https://ecovadis.com` the page the A Path button should open, or is there a customer-specific EcoVadis link or step for sharing a scorecard with The Corporate? | Builder | No, can be changed during build |
| Public URLs for the Supplier Code of Conduct and the Global Environmental Policy (to link from section 01) | Builder | No, added by iteration |
| Is the questionnaire workbook final for the 2027 cycle (its title and file name say 2026)? | Builder | No, the file can be swapped without changing the page |
| Final subject line wording for the return email | Builder | No |

---

## Section 16: Tool Version History

| Version | Date | What changed in the tool |
|---------|------|--------------------------|
| v1.0 | 9 November 2026 | Initial build |

---

*This spec is written for Claude Code. It assumes zero prior context.*
