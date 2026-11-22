# Product Spec: Supplier Sustainability Portal

**Version:** 2.1
**Date:** 20 November 2026
**Author:** Zyad Hatquai
**Status:** Confirmed
> Set to Confirmed by the Tool Architect when the builder confirmed the Phase 10 summary. The Project Governor accepts only this status.

---

## Section 1: Tool Summary

**Tool name:** Supplier Sustainability Portal

**What it does:** A single public web page that explains The Corporate's supply chain sustainability programme to its Tier 1 suppliers and lets each supplier take the required action on the page itself. A supplier with an EcoVadis scorecard records a short entry and goes to EcoVadis (A Path). A supplier without one submits The Corporate's questionnaire on the page, in one of two ways: by filling in a form, or by uploading the filled Excel workbook (B Path). Every submission is reviewed by the supplier, confirmed, and then saved. An uploaded workbook is only read to fill in the answers on screen; the file itself is never kept, and the confirmed answers are the submission.

**Who uses it:** Procurement contacts at The Corporate's 500+ Tier 1 suppliers, across all sourcing categories. They arrive from one link, issued through the Procurement Portal and reinforced by account manager outreach.

**Why it exists:** The Corporate reports value-chain sustainability performance under CSRD from the 2026 reporting cycle, and about 71% of its footprint sits with suppliers. Long manual surveys produce low response rates, and answers returned by email cannot be counted or compared. This page gives every supplier one clear route and gives The Corporate the answers in one place: ask once, and do not make suppliers with a recognised third-party rating repeat the work (the Smart Intake rule).

**Build status:** Iteration. The previous version is v2.0 (16 November 2026, Tier 2): submission through the tool by an on-page form or a workbook upload, a short record on the A Path, a database and private file storage. v2.0 was built on the branch `claude/affectionate-ptolemy-udznhn` (pull request 4), tested by the builder on its Deploy Preview on 20 November 2026 and not merged; the live site still runs v1.0 (9 November 2026, Tier 1, no database). This build (v2.1) changes four things found in that test, inside the same tier and access model: the A Path confirmation becomes one clear next step (Go to EcoVadis) with less text before the form; the seven Quantitative questions accept a number only, with their unit shown, checked on the page and again in the submit function; an uploaded workbook is read but never stored (no file storage, the bucket is removed); the supersede rule is confirmed unchanged. v2.1 ships in the same pull request as v2.0. The repo, the Netlify site, the live address and the Supabase project stay the same. Intent notes: `intent-2026-11-16.md` (v2.0) and `intent-2026-11-20.md` (v2.1). Source documents are unchanged: Supplier Engagement Programme 2026 Program Charter v1.0, Procurement Sustainability Strategy 2026 v1.0, and the Supplier Sustainability Assessment 2026 workbook. The programme documents are named "2026". This page runs the **2027 cycle**: all Charter dates are carried forward by one year (builder decision, 9 November 2026).

> **What this change overrides in CLAUDE.md** (the Project Governor rewrites them in Iteration Mode): "no database", "no form", "nothing stored", the footer line "This page does not collect or store any information about you", the "Return by email" rule, and the out-of-scope entries for upload and storing submissions. Still true: no cookies, no tracking, no analytics, no script beyond the page's own, the only external resource the page loads is the Google Fonts stylesheet, no credential in any file.
>
> **What v2.1 overrides in CLAUDE.md** (the Project Governor rewrites them in Iteration Mode): the storage bucket `submission-files`, `file_path` set on uploads, the upload of the file by `submit`, the 4 MB file limit on `submit` (it stays on `parse-workbook`), and the A Path's three numbered steps and its confirmation text.

---

## Section 2: Classification

### Data Model

**Decision:** D3

| Label | What it means | This tool? |
|-------|--------------|-----------|
| D1 Hardcoded | All data is written into the code by the developer. | No |
| D2 Session | Data enters during use and disappears when the tab closes. | No |
| D3 Persisted | Data is written to a database. Supabase required. | **Yes** |

**Reason:** Suppliers submit answers that The Corporate must be able to find and read after the session ends, so the data must persist.

**D3 triggers (check all that apply):**
- [x] Data must be retrievable after the session ends
- [x] Multiple sessions contribute to the same dataset
- [ ] An audit trail or history is needed
- [x] Data submitted by one person must be visible to another (The Corporate's programme team reads what suppliers submit)
- [ ] Results must be accessible via a URL after the session ends
- [ ] Files uploaded by users must be stored and retrievable later (no longer: since v2.1 an uploaded workbook is read and not kept)

### Access Model

**Decision:** A1

| Label | What it means | This tool? |
|-------|--------------|-----------|
| A1 Public | Anyone with the URL can use it. No login. | **Yes** |
| A2 Authentication | Users must log in, same rights for all. | No |
| A3 Authorization | Users must log in and have different roles. | No |

**Reason:** The page is one link sent to 500+ suppliers. A login would add friction, and the Charter lists supplier accounts as out of scope. Suppliers only write; they can never read anything back.

> **Target, not state:** A1 is the target for the supplier side. A later dashboard for The Corporate's own team (not in this build) is a second view of the same tool behind a login. When it is specced, the access model becomes A3 and the version moves to v3.0. This build adds no login and no profile table.

### Tier

**Tier:** 2 (D3 + A1: Netlify and Supabase, no login)

### Standalone or Stack

**This tool is:** Standalone. It shares no database with any other tool. The later dashboard is a second view of this same tool, not a second tool: one repo, one site.

---

## Section 3: Arms

No arm is active.

### AI API Arm
**Active:** No

### Export Arm
**Active:** No. The questionnaire is a static file the builder places in the site. It is not generated from data, so it is not an Export arm.

### Email Arm
**Active:** No. The tool sends no email. The supplier sees an on-screen confirmation. An email notice to inbox@thecorporate.com for each submission is deferred (Section 12); it needs a sending domain or a company mailbox.

### Scheduled Automation Arm
**Active:** No

> Natural-language search over documents is outside this framework and is not part of this tool.

### Public-tool protections (A1 with a form)

| Detail | Answer |
|--------|--------|
| Protections | Every public write goes through a Netlify Function that holds the Supabase secret key. The browser never writes to a table and never talks to Supabase. The function refuses an oversized body, refuses any request that carries a file, validates every field (including the number-only questions) and applies the supersede rule (Section 9). No anon policy and no anon grant on any table. No storage bucket exists. No rate limit. |
| Bot check | **Bot check: not in this version (known risk, see caution).** The caution is in Section 15. |

---

## Section 4: Stack and Deployment

### All Tiers

| Detail | Answer |
|--------|--------|
| Frontend framework | HTML/CSS/JS, no framework, no build step for the page. One `index.html` with linked CSS and JS, plus a static `about.html`. |
| Server code | Two Netlify Functions in `netlify/functions/`: `parse-workbook` (reads an uploaded workbook and returns its answers, stores nothing, keeps no file) and `submit` (validates and saves a confirmed submission: rows only, never a file). Node, with one `package.json` for the function dependencies (a library that reads .xlsx files, chosen by Claude Code in its plan) and the Supabase client. The page itself loads no library. |
| Deployment target | Netlify |
| Deployment | GitHub push, then Netlify auto-deploy. Always a branch, one per session (one intent). Claude Code works on the session's branch and pushes it; it never pushes to main or merges. The session ends with a pull request the builder opens on GitHub (Compare and pull request). Netlify builds a Deploy Preview of it, the builder runs the builder rows of `docs/checks.md` there, merges on GitHub and deletes the branch, and main deploys. A preview shows the branch's screens against the one live database, so migrations are additive (never drop or rename in the same change) and a table with real rows is exported before a migration touches it. Netlify is not connected to Claude: no Netlify connector or MCP is used. |
| Supabase and Netlify connection | **The Supabase extension in Netlify, never copy-paste.** Netlify dashboard, Extensions, Supabase, Install; then on the site, Connect, sign into Supabase, pick the project `the-corporate-sustainability` and the framework (choose Other and set the prefix to `VITE_` if Vite is not listed). The extension writes the project address and keys into the site's environment. Then redeploy. **When:** the project is new, so this is done after Claude Code creates it in the build session and before the first functional deploy. **Key check, once:** the values should start with `sb_`; if they start with `eyJ`, the extension wrote the retiring legacy keys, and the secret key's rotation becomes a dated handover item. A Netlify-to-Supabase link, set once; it has nothing to do with Claude. |
| Platform owner | The builder, on their own Netlify and Supabase accounts. (Builder decision default; change if the page moves to a company account. The handover package covers the move.) |

**GitHub:** the repo `ZHatquai/supplier-portal-cohort-3` exists and is reused. The new intent note and this spec travel with the build in the session's pull request.

### Supabase project

**Supabase project status:** Existing. Created by the builder on 16 November 2026 (v2.0 build session): `the-corporate-sustainability`, ref `huahhrvlvkqktvvimylo`, EU region Frankfurt (eu-central-1). Connected to the Netlify site with the Supabase extension; the builder confirmed on 20 November 2026 that the key values start with `sb_`. Claude Code reads `docs/supabase-setup.md` before any schema change.

**Supabase plan:** Free, for building and testing: no backups, and paused after roughly one week without use. **Switches to Pro before the first supplier wave** (about 25 US dollars a month per organisation; daily backups kept 7 days; never paused). The handover package explains the cost.

| Detail | Answer |
|--------|--------|
| Proposed project name | the-corporate-sustainability |
| Confirmed project name | the-corporate-sustainability (confirmed by the builder, 16 November 2026) |
| Project ID | huahhrvlvkqktvvimylo |
| Region | EU, Frankfurt (eu-central-1), because the data is personal data of suppliers' staff |

> The project exists. v2.1 changes it through one named migration (Section 14) and the builder's removal of the bucket on the Supabase Storage page.

**supabase-setup.md:** exists (written in the v2.0 build session), updated whenever the database is touched. It records the project name and ID, all tables and fields, RLS policies, and (since v2.1) that no storage bucket is used.

### Stack

Not applicable. Standalone.

---

## Section 5: Data Architecture

### What is collected or stored

All of it is provided by the supplier on the page, except the fields marked Automatic. Suppliers never read anything back.

**Table `submissions`: one row per confirmed submission** (the A Path short entry, a form submission or an upload)

| Field name | Plain language label | Data type | Who provides it | Required? |
|-----------|---------------------|-----------|----------------|-----------|
| id | Reference | Unique id | Automatic | Yes |
| route | Which way it came: `ecovadis`, `form` or `upload` | Text | Automatic (from what the supplier did) | Yes |
| company_name | Company legal name | Text | Supplier | Yes |
| company_country | Registered country | Text | Supplier | Yes for `form` and `upload`; not asked on `ecovadis` |
| contact_name | Contact name | Text | Supplier | Yes |
| contact_title | Contact title | Text | Supplier | No |
| contact_email | Contact email | Text | Supplier | Yes |
| ecovadis_link | EcoVadis scorecard link | Text | Supplier | No |
| declaration_name | Authorised signatory name | Text | Supplier | Yes for `form` and `upload` |
| declaration_date | Declaration date (DD Month YYYY) | Date | Supplier | Yes for `form` and `upload` |
| declaration_confirmed | "I confirm the information is accurate and complete" ticked | Yes/No | Supplier | Yes for `form` and `upload` |
| file_path | Unused since v2.1: always empty, enforced by a database check. Kept because a column is never dropped in an iteration. | Text | Nobody | No |
| reading_status | `not_applicable` (form, ecovadis) or `read` (upload: the answers were read from a workbook and confirmed by the supplier) | Text | Automatic | Yes |
| company_key | Company name and contact email, lower-cased and trimmed, joined; the supersede key | Text | Automatic | Yes |
| status | `received` or `superseded` | Text | Automatic | Yes |
| created_by | Empty until a login exists | Id | Automatic | No |
| created_at, updated_by, updated_at | Audit columns | Date/Id | Automatic | Yes (updated_by empty) |

**Table `submission_answers`: one row per question answered, 30 questions per full submission**

| Field name | Plain language label | Data type | Who provides it | Required? |
|-----------|---------------------|-----------|----------------|-----------|
| submission_id | Which submission | Id | Automatic | Yes |
| question_id | Workbook question id, `S1-1` to `S7-5` (the question list below) | Text | Automatic | Yes |
| response | Supplier response | Text, up to 4,000 characters | Supplier | No, except S1-1 and S1-2 |
| evidence_note | Notes and evidence | Text, up to 4,000 characters | Supplier | No |

`ecovadis` submissions have no answer rows.

**File storage:** No (since v2.1). An uploaded workbook is sent to `parse-workbook`, read in memory to fill the review screen and discarded; it is never written to storage, a table or a log. The answers the supplier confirms are the submission. The v2.0 bucket `submission-files` (private) is emptied and removed by the builder on the Supabase Storage page as part of this change (Supabase refuses SQL deletes of stored files, so this is a dashboard step); `submit` no longer has any storage call.

**Main record and its states**

| Detail | Answer |
|--------|--------|
| Main record | One row = one confirmed submission |
| States, in order | `received`; a newer submission from the same company and email changes the older one to `superseded` (final) |
| Login-ready columns | `created_by`, `status`, `created_at`, `updated_by`, `updated_at` on both tables. No `profiles` table: no login target is named yet (Section 6). |

**Derived or calculated data:** No. Nothing is scored or calculated. The PFAS answer is stored like any other; there is no automatic flag.

### The question list (the form, the upload reading and `submission_answers` all use it)

Thirty questions from the sheet "Supplier Assessment 2026" of the workbook, in the workbook's own order. Question text, ESRS reference and the dropdown options are taken from the workbook itself (its data validations); Claude Code reads them from the file and never invents or rewords them. Dropdown answers are stored as the option text. The workbook's column G (Status) is not used. The seven Quantitative questions are number-only (v2.1, the number rule in Section 9): the unit is shown next to the field, and what the question asks beyond the number goes in its evidence note, whose label says so.

| Id | Workbook row | Section | ESRS | Type | Subject | On the form |
|----|--------------|---------|------|------|---------|-------------|
| S1-1 | 6 | S1 General information | none | Required | Legal name and registered country | Two fields: company name, country. Required. |
| S1-2 | 7 | S1 | none | Required | Primary contact name, title, email | Three fields: name (required), title (optional), email (required). |
| S1-3 | 8 | S1 | Bypass | Dropdown | Holds a valid EcoVadis scorecard | Prefilled from the choice in the question panel (No), not editable. |
| S1-4 | 9 | S1 | none | Conditional | EcoVadis scorecard link | Optional. |
| S2-1, S2-2, S2-3 | 11, 12, 13 | S2 Climate and decarbonisation | E1-4 | Quantitative | Scope 1, Scope 2 (market-based), Scope 3 emissions | Optional. Number only, unit tCO2e. Note label: S2-1 "Verification method and notes", S2-3 "Categories included and notes". |
| S2-4 | 14 | S2 | E1-3 | Dropdown | Science-Based Target | Optional. |
| S2-5, S2-6 | 15, 16 | S2 | E1-2 | Open-ended | Top three decarbonisation projects; barriers to a 50% reduction | Optional. |
| S3-1 | 18 | S3 Pollution and PFAS | E2-3 | Quantitative | Substances of concern used | Optional. Number only, unit kg. |
| S3-2 | 19 | S3 | E2-3 | Dropdown | PFAS compounds | Optional. |
| S3-3 | 20 | S3 | E2-3 | Open-ended | PFAS substitution roadmap | Optional. |
| S3-4 | 21 | S3 | E2-2 | Open-ended | Industrial wastewater treatment | Optional. |
| S4-1 | 23 | S4 Water and marine resources | E3-1 | Quantitative | Total water withdrawal | Optional. Number only, unit m3. Note label: "Source and notes". |
| S4-2 | 24 | S4 | E3-1 | Dropdown | High-water-stress region | Optional. |
| S4-3, S4-4 | 25, 26 | S4 | E3-2 | Open-ended | Water-saving projects; contingency plan | Optional. |
| S5-1 | 28 | S5 Circular economy and waste | E5-2 | Quantitative | Total waste generated | Optional. Number only, unit tonnes. Note label: "Breakdown and notes". |
| S5-2 | 29 | S5 | E5-4 | Quantitative | Post-consumer recycled content | Optional. Number only, unit %, from 0 to 100. |
| S5-3 | 30 | S5 | E5-3 | Open-ended | Circularity in supplied components | Optional. |
| S5-4 | 31 | S5 | E5-2 | Open-ended | Zero Waste to Landfill strategy | Optional. |
| S6-1 | 33 | S6 Biodiversity and ecosystems | E4-2 | Dropdown | Sites in or near a protected area | Optional. |
| S6-2 | 34 | S6 | E4-3 | Open-ended | Biodiversity initiatives | Optional. |
| S6-3 | 35 | S6 | E4-5 | Open-ended | Biodiversity impact assessment | Optional. |
| S7-1 | 37 | S7 Social, labour and governance | S2-1 | Dropdown | Human and labour rights policy | Optional. |
| S7-2 | 38 | S7 | S2-2 | Dropdown | Human rights due diligence assessment | Optional. |
| S7-3 | 39 | S7 | S2-4 | Open-ended | Grievance mechanism | Optional. |
| S7-4 | 40 | S7 | G1-1 | Dropdown | Conflict minerals policy | Optional. |
| S7-5 | 41 | S7 | G1-2 | Open-ended | Supplier code of conduct and monitoring | Optional. |

Each question except S1-1 to S1-3 also has an evidence note field (the workbook's column F). The declaration at the bottom of the workbook (row 43) is not read from the file: on both routes the supplier types the declaration in the tool (Section 8, Review and confirm).

---

## Section 6: Access and Permissions

Not applicable in this build. Access model is A1: no login, no roles, no accounts. Suppliers write only; no screen shows a stored record.

**Planned later, not part of this build:** a dashboard showing every submission, for The Corporate's own team. It will need a login and a reading role. **The first reader is not named yet** (builder, 16 November 2026: "we discuss later"). Because no login target is named, no `profiles` table is created now; the database already carries the login-ready columns (Section 5), so the dashboard is a later migration. When the dashboard is specced, it runs as a change (Tool Architect in Iteration Mode, then the Access Architect's full run) and the version moves to v3.0.

The row-level access rules for this build live in `access-matrix.md`, produced by the Access Architect's short run (write-only rules: the browser has no access to any table, and since v2.1 no storage bucket exists; only the submit function, holding the secret key, writes). This section does not duplicate the grid.

---

## Section 7: GDPR

**GDPR outcome:** Applies. The tool now collects personal data through its form and uploads.

**Personal data collected:**
- Contact name, contact title, contact email
- Authorised signatory name (declaration)
- Any personal data a supplier types into a free-text answer or evidence note, or that is inside a workbook they upload (the S1 contact details; suppliers are asked to enter business information only). The workbook is read in memory to fill in the answers and is not kept; only the answers the supplier confirms are stored.

Company name and country are business data, not personal data. The tool holds no login identities (no login exists).

**Lawful basis:** Contract or legitimate interest: suppliers submit what The Corporate's supplier programme requires. Derived by the Tool Architect from the tool type and confirmed by the builder as a starting point. The Corporate's privacy contact signs it off (Section 15). Consent is the wrong basis here because a supplier cannot freely refuse a programme requirement.

**Notice on the form:** Yes, always, shown wherever personal data is entered (the A Path short entry, the form, the upload and review screen) and repeated on the About page. **Consent checkbox:** none, because the basis is not consent. The declaration tick is a confirmation of accuracy, not a consent.

**Data notice text** (draft, for the privacy contact's sign-off):
> The Corporate (inbox@thecorporate.com) stores this data to run its 2027 supplier sustainability programme and to meet its sustainability reporting obligations, on the basis of contract or legitimate interest. It is kept until you ask for it to be deleted. It is held on Supabase (EU region) and served by Netlify. You can ask to see, correct or delete your data by contacting inbox@thecorporate.com, and you can complain to your data protection authority.

**Retention:** Until deleted on request (builder decision, 16 November 2026). There is no fixed period. This is the weakest form of retention wording; the privacy contact may require a fixed period (Section 15).

**Deletion mechanism:** A supplier writes to inbox@thecorporate.com. The Corporate's programme team passes the request to the platform owner, who deletes every submission from that company and contact email (the `received` row, every `superseded` row and their answer rows; no file is stored) in the Supabase dashboard or with a Claude Code admin command, and confirms to the requester. "Deletion" in this tool means the rows are removed, not anonymised.

**Standing line for the page footer:** Replaced (Section 8, Footer). The v1.0 line "This page does not collect or store any information about you" is no longer true and must not appear.

---

## Section 8: Screen and UI Structure

One page, one URL, five stacked blocks plus header and footer, and one static About page. English only. Anchor links in the header jump to each numbered section. All copy follows the voice rules in Section 10. Sections 01 and 02 are unchanged from v1.0 and carry over word for word.

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

### 03 How this works (changed: Route B text)

- **Purpose:** Show the two routes and the timeline before the supplier chooses.
- **What is visible:**
  - H2 and one sentence: one portal, one assessment, two routes.
  - Two cards side by side:
    - **Route A, EcoVadis.** Hold a valid EcoVadis scorecard? Tell us who you are, then submit it on EcoVadis and you are exempt from the detailed assessment. Validations are processed weekly.
    - **Route B, Full assessment.** No current scorecard? Complete The Corporate's sustainability assessment across the priority themes and submit it on this page, by filling in the form or by uploading the completed Excel workbook.
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

### 04 What you can do (changed: both paths now submit through the page)

- **Purpose:** Let the supplier choose the route and complete it on the page.
- **What is visible at first load:**
  - H2: "What you can do".
  - **The question panel (Acid Lime use 2 of 2, Pattern B, 2px lime left border):** H3 "Do you have an EcoVadis Scorecard?" with a small helper line: "A valid scorecard is one issued within the last 12 months."
  - Two equal buttons side by side: "Yes, I have one" and "No, I do not". Neither is preselected. Both are real buttons, reachable by keyboard, and expose their state to screen readers (`aria-pressed`, and the paths use `aria-expanded` with `aria-controls`).
  - Both paths are closed.

**A Path (opens when Yes is chosen)** (changed in v2.1: less text, one next step)
- Heading "Route A: submit your EcoVadis scorecard".
- One line: "Tell us who you are, then share your scorecard with The Corporate on EcoVadis."
- **Short entry form:** company name (required), contact name (required), contact email (required), EcoVadis scorecard link (optional). The data notice (Section 7) sits directly above the submit button. Button: "Save and continue".
- On success, the form is replaced by the confirmation, headed "One step left", with one line: "Share your scorecard with The Corporate on EcoVadis." Directly under it, the single primary button "Go to EcoVadis", linking to `https://ecovadis.com`, opening in a new tab with `rel="noopener noreferrer"`. Below the button, one small line: "Saved on [DD Month YYYY] for [company name]. Reference [reference]." It is never an automatic redirect (pop-up blockers stop tabs that open on their own, and a same-tab redirect takes the supplier away from the page). Focus moves to the "One step left" heading.
- On a save failure: the error message (below), a "Try again" button, and the same "Go to EcoVadis" link shown beneath the error, so a technical fault never blocks a supplier from the route. Their typed entries stay on the screen.
- A text link "I do not have one" that switches to the B Path.
- Removed in v2.1: the three numbered steps and the line "The Corporate validates EcoVadis submissions weekly." on this panel (section 03 still says that validations are processed weekly).

**B Path (opens when No is chosen)**
- Heading "Route B: complete the questionnaire".
- A bordered preview list of the workbook sections: S1 General information and EcoVadis question; S2 Climate and decarbonisation (E1); S3 Pollution and PFAS (E2); S4 Water and marine resources (E3); S5 Circular economy and waste (E5); S6 Biodiversity and ecosystems (E4); S7 Social, labour and governance (S2, G1).
- Secondary button "Download questionnaire (.xlsx)" with the file name and a "Microsoft Excel" label. This stays so suppliers can fill the workbook in offline and upload it.
- A choice of two ways, shown as two equal buttons ("Fill in the form" and "Upload the filled workbook"), neither preselected. Choosing one opens its panel and closes the other; switching replaces the visible panel.
- A text link "I have a scorecard after all" that switches to the A Path.
- A note: PFAS answers are reviewed by The Corporate's EHS team. (No SLA is stated.)

**Fill in the form (inside the B Path)**
- Seven blocks, S1 to S7, in the workbook's order, each headed with the section name and ESRS reference. Each question shows its text, its ESRS reference, whether it is required, its answer control (a text field, a number field with its unit, a dropdown with the workbook's own options, or a text area, by the workbook's Type) and an evidence note field. A number field is a text field that opens the decimal keypad on phones, with its unit (tCO2e, kg, m3, tonnes, %) shown next to it; anything that is not a number shows "Enter a number only, for example 12345 or 12,345.6. Put any other detail in the notes." (for S5-2: "Enter a percentage from 0 to 100."). The exact question list, which questions are required and the one prefilled question are in Section 5.
- Required marking, inline validation messages in plain words, and focus moves to the first error on a failed attempt.
- Button "Review your answers" (does not save).

**Upload the filled workbook (inside the B Path)**
- Instructions: use the questionnaire downloaded from this page, do not move or rename rows or the sheet, .xlsx only, up to 4 MB. One line: "We read your file to fill in the answers for you to check. The file itself is not kept."
- A file chooser (a real control, reachable by keyboard; drag and drop is optional) and a button "Read the file". The file is sent to the page's server function, which reads the answers and returns them. Nothing is saved at this point, and the file is never kept, then or later.
- On success: the Review and confirm screen opens with the extracted answers filled in. A number question whose cell holds text (for example "approx. 1200 t") does not make the file fail: the answer is shown in its field, marked with the number message, and "Confirm and submit" stays disabled until it holds a valid number or is emptied.
- On failure (wrong file type, over 4 MB, not the workbook, rows moved, sheet renamed, file unreadable): the error message "We could not read this file. Please use the questionnaire downloaded from this page, or fill in the form instead." The supplier can choose another file or switch to the form. Nothing is saved and no file is kept.

**Review and confirm (both ways end here)**
- Purpose: the supplier checks everything before anything is saved.
- What is visible: a read-only list of every answer and evidence note grouped S1 to S7, with an "Edit" control that returns to the form (for an upload, the answers become editable fields). Company name, country, contact name and contact email are separate fields, prefilled from the file where they can be read (the workbook holds them as free text in one cell), and always confirmed by the supplier. The declaration: the workbook's own declaration text, an authorised signatory name field, a date field (DD Month YYYY, prefilled with today and editable), and a tick box "I confirm that the information provided is accurate and complete". The declaration is never read from an uploaded file. The data notice sits directly above the confirm button.
- User actions: edit, go back, confirm. Button "Confirm and submit" is disabled until the required fields and the declaration are complete and every number question holds a valid number or is empty, and is disabled while saving, so a double press cannot save twice.
- What happens next: on success, the Confirmation screen. On a save failure: the error message with "Try again", the answers still on screen, nothing lost.

**Confirmation**
- "Submission received." The date (DD Month YYYY), the company name, a reference number (the row id, shortened for display), and one line: "Submitting again with the same company name and contact email replaces this submission." No email is sent. A "Download questionnaire" link is not repeated.

**Error messages (plain words, no exclamation points)**
- Save failed: "We could not save your submission. Nothing was recorded. Please try again."
- Required field empty: "Enter [field name]."
- Email invalid: "Enter a valid email address."
- Text too long: "This answer is too long. The limit is 4,000 characters."
- Not a number: "Enter a number only, for example 12345 or 12,345.6. Put any other detail in the notes." (S5-2: "Enter a percentage from 0 to 100.")
- File unreadable: as above.

- **User actions (whole section):** choose Yes or No (switchable at any time), fill the short entry, go to EcoVadis, download the workbook, choose a way to submit, fill the form or upload the file, review, edit, confirm.
- **What happens next:** the supplier leaves for EcoVadis (A, after the short entry is saved), or finishes on the Confirmation screen (B). The page stores nothing in the browser; a reload returns to the neutral state and clears anything typed.

### About this tool (new page, `/about.html`, linked from the footer of every screen)

- **Purpose:** Tell suppliers what the tool is, who runs it and what happens to their data. Operational transparency; not the data notice (which stays on the forms, Section 7).
- **What is visible:** what the page is for and that The Corporate's Group Procurement and EHS and Sustainability run it, with the contact inbox@thecorporate.com; what it stores and about whom (contact name, title, email, signatory name and the answers; an uploaded workbook is read to fill in the answers and is not kept; Section 5 in plain words); where the data is kept and processed (Supabase, EU region, and Netlify; no other provider); how long it is kept and how to ask for correction or deletion (Section 7); that there is no login and no supplier account; that the page uses no cookies and no tracking; version 2.1 and last updated 20 November 2026 (set to the merge date when built).
- **User actions:** read; follow the contact link; return to the page.
- **What happens next:** nothing; it is a page. Built last, before deploy.

### Footer

- **Purpose:** Contact and the standing data line.
- **What is visible:** logo, "Questions about this programme? inbox@thecorporate.com", the line "Data you submit on this page is stored by The Corporate. This page uses no cookies and no tracking.", a link "About this tool", "The Corporate, Group Procurement and EHS and Sustainability", and the "2027 cycle" label.

### Responsive and accessibility behaviour (applies to every view)

- Works from 360px wide: grids collapse to one column below 768px, 16px side padding, no horizontal scroll. The form and the review screen are usable on a phone, and every button is at least 44px tall.
- Colour contrast meets WCAG AA. Lime is used only on Ink.
- Visible keyboard focus on every control, including the file chooser, the dropdowns and the tick box.
- Opening a path or moving to Review and Confirmation moves focus to that panel's heading. Validation messages are announced to screen readers and tied to their fields.
- The page honours `prefers-reduced-motion`.
- The only network calls are the two page functions (`/.netlify/functions/parse-workbook` and `/.netlify/functions/submit`), the Google Fonts stylesheet, the workbook download and the outbound EcoVadis link. The browser never calls Supabase.

---

## Section 9: Logic and Calculations

No calculation or scoring. The rules:

**Question panel rule:** Yes shows the A Path and hides the B Path. No shows the B Path and hides the A Path. Switching replaces the visible path. Before any choice, neither path is visible. The choice is held in memory for the visit only and is not stored anywhere. A reload returns to the neutral state.

**Nothing is saved before confirmation.** On the A Path, saving happens when the supplier presses "Save and continue". On the B Path, saving happens only when the supplier presses "Confirm and submit" on the Review and confirm screen. Reading an uploaded file (`parse-workbook`) saves nothing: no row, no file. Confirming saves rows only: no file is stored at any point.

**Reading the uploaded workbook:**
- Accept only .xlsx, up to 4 MB (the platform's request limit is about 6 MB and the file travels encoded, so 4 MB is the safe ceiling).
- The workbook must contain the sheet "Supplier Assessment 2026", and the 30 question rows of Section 5 must sit at their rows with the question text matching the expected text for each id. Otherwise the file is refused with the error message in Section 8.
- For each question, the supplier response is read from column E and the evidence note from column F. Empty cells are empty answers, not errors. Column G is ignored. Cell formulas are treated as text; the file is never executed. A number cell is read as the number; a number question holding text is returned as it is (not an error) and is marked on the review screen.
- The reference workbook, unfilled, reads as 30 empty answers without error.
- The declaration (row 43) is never read.

**Required fields:** company name, country, contact name, contact email, and (B Path) the declaration name, date and confirmation tick. Everything else is optional. The email must look like an email address. Each answer and note is at most 4,000 characters.

**Number rule (v2.1):** S2-1, S2-2, S2-3 (tCO2e), S3-1 (kg), S4-1 (m3), S5-1 (tonnes) and S5-2 (%) are optional, but when answered they hold a number only. Accepted: digits with an optional decimal point, and commas only as thousands separators in groups of three, for example `12345`, `12,345`, `12345.6`, `12,345.6`, `0`; spaces around the value are trimmed. Refused: letters, a typed unit, a negative sign, any other character, and a comma not in a group of three (such as `12,5`, which could be a decimal comma). S5-2 must also be from 0 to 100. The value is stored as the number without separators (`12,345.6` is stored as `12345.6`). The page checks it on the form and on the review screen; `submit` checks it again and refuses the request if any of the seven is not a number.

**Supersede rule:** a submission's key is the company name and contact email, lower-cased and trimmed. When a new submission is saved with a key that already has a `received` row, the older row's status becomes `superseded` in the same step, and the new row is `received`. There is exactly one `received` row per key. Superseded rows are kept until deleted on request. (Unchanged in v2.1; confirmed by the builder's test on 20 November 2026.)

**Both ways, one result:** a form submission and an upload submission produce the same rows in `submission_answers`; only `route` and `reading_status` differ. `file_path` is always empty.

**Edge cases:** the supplier closes the tab before confirming: nothing was saved. The server is unreachable: the error message with Try again, answers kept on screen. A request to `submit` that carries a file: refused, nothing saved. Two quick presses of Confirm: the button is disabled while saving; the supersede rule keeps one `received` row regardless. A file with extra sheets: only the named sheet is read. A supplier submits the A Path and later the B Path with the same company and email: the later one supersedes the earlier one.

---

## Section 10: Brand and Visual Direction

**Brand reference:** the `the-corporate-brand` skill (The Corporate brand specification), at `.claude/skills/the-corporate-brand/SKILL.md`. Claude Code reads it before writing any page code and copy.

**Visual feel:** Professional and corporate. Corporate minimalism, restraint over decoration. The new form, review and confirmation screens follow the same system as the rest of the page: no new accent colour, no red for errors (errors are Ink text on Linen with a 0.5px Ink border and a plain word label), no icons, no emoji.

**Rules lifted from the brand skill that the build must follow:**
- Colours: Ink `#000000`, Stone `#B6B09F`, Linen `#EAE4D5`, Chalk `#F2F2F2` (page background), White, and Acid Lime `#C8F135` used **twice at most per page** and only against Ink. The two uses are the deadline badge (Section 8, hero) and the question panel (Section 8, section 04). The new screens add no lime.
- Fonts: Playfair Display for headlines (H1 700, H2 400), DM Sans for everything else (body 300 at 15px, line-height 1.75), loaded from Google Fonts.
- Square corners everywhere. Hairline 0.5px borders. No shadows, no gradients, no decorative fills.
- Buttons: primary Ink fill with Chalk text, secondary transparent with an Ink hairline border, uppercase with 0.1em tracking. Form fields are White with a 0.5px Ink border.
- Logo: black square box with the "C", wordmark in DM Sans Light, tracked 0.12em. Never recoloured. No logo files exist in the repo; the logo is drawn as inline SVG or CSS.
- Max page width 1120px, body text column 720px.
- Copy: short declarative sentences, active voice, no exclamation points, no emoji, no vague qualifiers, dates as DD Month YYYY, Oxford comma, numerals for data. No em dashes in running prose.

**Reference or inspiration:** the look of the Charter and Strategy PDFs: numbered section labels (01 to 04), tracked uppercase eyebrow labels, hairline tables, large figure numerals.

---

## Section 11: API and Credentials

| Service | What it does in this tool | Key required | Where key is stored |
|---------|--------------------------|-------------|-------------------|
| Supabase | Database (two tables). No file storage since v2.1. Used only by the `submit` function (`parse-workbook` does not connect to Supabase). | **Secret key** (`sb_secret_...`; server-side only, bypasses RLS, never in browser code) and the project address. A publishable key is also written by the extension but this tool's code does not use it, because the browser never talks to Supabase. | Netlify environment variables, written by the Supabase extension; value checked once (starts with `sb_`) |
| Public-tool protections (A1) | Every public write goes through the submit function; it refuses an oversized body and any file, validates every field including the number rule, applies the supersede rule; no anon policy or grant. No rate limit. No bot check. | None (uses the Supabase secret key above) | Not applicable |
| Netlify | Hosting, the two functions, the Deploy Previews | None in code | Netlify dashboard |
| Google Fonts | Stylesheet link | None | Not applicable |
| EcoVadis | Outbound link only | None | Not applicable |

- No AI, email or other API is used. The only external resource the page loads is the Google Fonts stylesheet.

**Environment variable contract: the exact names Claude Code reads, never a value**

| Variable name (exact) | Read by | Set where | Public or secret |
|-----------------------|---------|-----------|------------------|
| `VITE_SUPABASE_URL` | the Netlify Functions, as the project address (the page itself does not use it) | Netlify env, written by the Supabase extension | public |
| `VITE_SUPABASE_ANON_KEY` | nothing in this tool | Netlify env, written by the Supabase extension | public; its value is the publishable key; the variable keeps its historical name and is not used |
| `SUPABASE_SERVICE_ROLE_KEY` | Netlify Functions only | Netlify env, written by the Supabase extension | **secret**; its value is the secret key (`sb_secret_...`); never in client code, never in a file |
| `SUPABASE_DATABASE_URL` | nothing, unless a function needs a direct connection | Netlify env, written by the Supabase extension | secret |

> The names and values are verified on the first live build; if the extension writes different names or legacy values (`eyJ`), this table is corrected in the same session. The Governor derives its environment-variable list from this table and from nothing else.

**Credentials readiness:**

| Credential | Status | Where to get it |
|-----------|--------|----------------|
| Supabase URL, publishable key, secret key | Written into Netlify by the Supabase extension once the project exists and the site is connected. Not available before the build session. | Netlify, site, Connect (Supabase extension) |

> **Security rule, no exceptions:** no API key, token, password or credential may appear in any HTML file, any JavaScript file served to the browser, or any file committed to GitHub. The secret key lives only in the Netlify environment and is read only inside the two functions.

---

## Section 12: Out of Scope, Phase 2

Claude Code builds nothing listed here.

| Deferred feature | Reason it is deferred |
|-----------------|----------------------|
| **Dashboard showing every submission** | Builder, 16 November 2026: later, not in this build. Needs a login and a reading role (change lane, v3.0). The database is built login-ready. |
| A named dashboard reader and the login itself | Not decided ("we discuss later") |
| Supplier login and saved progress, including saving a half-finished form to continue later | Charter lists supplier accounts as out of scope this phase |
| Supplier editing or withdrawing a submission after confirming | A new submission replaces the old one; no edit screen |
| Email notice to inbox@thecorporate.com for each submission, and any confirmation email to the supplier | Needs a sending domain or a company mailbox; the tool works without it |
| Bot check (Cloudflare Turnstile) | Not built by default; known risk, see Section 15 |
| Rate limit, queue, retry, virus scan or monitoring | Complexity filter: not in place; they are named in the handover package with what each would take |
| Automated scoring of answers, including an automatic PFAS flag | Charter out of scope |
| In-tool Scope 3 calculation | Charter out of scope |
| Programmatic EcoVadis validation | Charter out of scope |
| Languages other than English | Validate the core page first |
| Links to the Supplier Code of Conduct and the Global Environmental Policy | No public URLs supplied yet; added by iteration when available |
| Return by email | Removed in v2.0: submission is through the tool |
| Storing the uploaded workbook file | Removed in v2.1: the file is read to fill in the answers and is not kept; the confirmed answers are the submission |
| Decimal commas in number fields (`12,5`) | Not in v2.1: refused as ambiguous; a later change if suppliers need it |

---

## Section 13: Acceptance Criteria (the checks)

The Project Governor writes this section out as `docs/checks.md`. A failing check is fixed in the tool, never in the check. Rows D2, S4, S6, S7, S9, S11 and S12 of v1.0 change meaning in v2.0; all others keep their id. In v2.1, rows D9, D10, D11, D12, D13, D15, D16, S6, S13, S14 and S16 change meaning, and D19, D20 and D21 are new. Fixtures live in `fixtures/` at the repo root (never served, never in `site/`): `workbook_filled.xlsx` (a copy of the reference workbook that Claude Code fills with made-up values, 30 known answers; the reference file itself is never edited), `workbook_wrong_layout.xlsx` (rows moved), `not_a_workbook.pdf`, `workbook_oversize.xlsx` (over 4 MB), and (v2.1) `workbook_text_in_numbers.xlsx` (the filled fixture with text in S2-1 and S4-1). Check rows that save data run against the Deploy Preview's database after a clean-up of their own test rows, or against a throwaway Supabase branch if the builder chooses one.

**Data checks**

| # | Given (fixture or action) | Expected result | Performed by |
|---|---------------------------|-----------------|--------------|
| D1 | The built site's `/downloads/` file compared with `reference/The_Corporate_Supplier_Questionnaire_2026_39.xlsx` | Identical bytes (checksum match). The file opens and its sheet "Supplier Assessment 2026" has 7 sections, S1 to S7. | Claude Code, verifier |
| D2 | Search the built HTML for `mailto:` and for "Return by email" | No "Return by email" button or link and no `mailto:` link with the subject "Supplier Sustainability Assessment". The address inbox@thecorporate.com appears only as text (footer, notice, About page). | Claude Code, verifier |
| D3 | The "Go to EcoVadis" link in the built HTML | `href` is `https://ecovadis.com`, `target="_blank"`, `rel` contains `noopener`; it is the only link to EcoVadis | Claude Code, verifier |
| D4 | Search the built output and the repo for `ecovadis`, `api_key`, `secret`, `token`, `eyJ`, `sb_secret`, `service_role`, and for the strings `690,000`, `RACI`, `15 business days`, `escalat` | The EcoVadis link appears. No credential string or key value appears anywhere in the repo or in `site/`. The words `SUPABASE_SERVICE_ROLE_KEY` appear only as a variable name inside `netlify/functions/` and in docs. None of the four internal-only terms appears in any page text. | Claude Code, verifier |
| D5 | Timeline text | Shows April 2027, 30 September 2027, Q4 2027 and Q1 2028, and no 2026 date | Claude Code, verifier |
| D6 | The four figures | 71%, 500+, 2045 and 50% appear, and no other tCO2e figure appears | Claude Code, verifier |
| D7 | `netlify.toml` and the deployed folder | `publish = "site"`, the functions directory set, no build command for the page; the site folder holds only index.html, about.html, css, js, assets and downloads, so nothing under docs/, reference/, fixtures/, .claude/ or netlify/ is served as a file | Claude Code, verifier |
| D8 | `parse-workbook` called with `fixtures/workbook_filled.xlsx` | Returns exactly the 30 known responses and evidence notes, each under its question id; the declaration is not returned. The unfilled reference workbook returns 30 empty answers and no error. | Claude Code, verifier |
| D9 | `parse-workbook` called with `workbook_wrong_layout.xlsx`, `not_a_workbook.pdf`, `workbook_oversize.xlsx`, and an empty body | Each returns the "We could not read this file" error (or the size message). No rows are created. | Claude Code, verifier |
| D10 | `parse-workbook` called with `workbook_filled.xlsx`; count the rows of both tables and the objects in Supabase storage before and after | The counts are identical: reading saves nothing. `parse-workbook` loads no database or storage client. | Claude Code, verifier |
| D11 | `submit` called with a valid form payload (route `form`, 30 answers, declaration, the seven number answers in mixed accepted formats such as `12,345.6`) | One `submissions` row (status `received`, route `form`, `file_path` empty), 30 `submission_answers` rows with the number answers stored without separators (`12345.6`), and a confirmation with the date and a reference | Claude Code, verifier |
| D12 | `submit` called with a valid upload payload (route `upload`, the 30 answers read from `workbook_filled.xlsx`, no file); then the same payload with a file attached | The first: one `submissions` row (route `upload`, reading_status `read`, `file_path` empty), 30 answer rows, and no object in Supabase storage. The second is refused and saves nothing. | Claude Code, verifier |
| D13 | `submit` called with a missing company name, then an invalid email, then a missing declaration tick, then an unknown question id, then a 4,001-character answer, then letters in S2-1, then a body over the size limit | Each is refused with a clear message; no rows are created | Claude Code, verifier |
| D14 | `submit` called twice with the same company name and contact email (different answers) | Exactly one row is `received` (the newer) and the older is `superseded`; both are kept | Claude Code, verifier |
| D15 | `submit` called with a valid A Path entry (route `ecovadis`) and then without a contact email | The first creates one `submissions` row (route `ecovadis`) with no answer rows, and the row is still there when the table is read afterwards; the second is refused | Claude Code, verifier, builder (row seen in the Supabase Table Editor after an A Path test on the Deploy Preview) |
| D16 | With the publishable (anon) key and with no key, try to read, insert, update and delete rows in `submissions` and `submission_answers`, and to list buckets or files in storage | Every attempt is refused or finds nothing. RLS is enabled on both tables from creation, with no anon policy and no anon grant; no storage bucket exists. The Supabase security advisor reports no open table. | Claude Code, verifier |
| D17 | Load the page and make every kind of submission in a browser session; list the network requests | Requests go only to the page's own address (the two functions, the workbook), the Google Fonts stylesheet and font files, and the EcoVadis link when followed. No request goes to a Supabase address. No cookie is set. | Claude Code, verifier |
| D18 | The built page's text | The v1.0 line "This page does not collect or store any information about you" does not appear anywhere. The footer line and the data notice from Sections 7 and 8 do. | Claude Code, verifier |
| D19 | The number rule, in `submit` and in the page's check, with these values for S2-1: `12345`, `12,345`, `12345.6`, `12,345.6`, ` 0 `; then `12a`, `approx. 1200`, `1200 t`, `-5`, `12,5`, `1,23,456`; and S5-2 with `100` and `101` | The first five are accepted and stored as `12345`, `12345`, `12345.6`, `12345.6`, `0`; each of the next six is refused with the number message and nothing is saved; S5-2 `100` is accepted and `101` refused. The page and `submit` agree on every value. | Claude Code, verifier |
| D20 | `parse-workbook` called with `workbook_text_in_numbers.xlsx` (text in S2-1 and S4-1) | It returns 30 answers and no error; S2-1 and S4-1 come back as the text in their cells | Claude Code, verifier |
| D21 | Search `netlify/` for any storage call (`storage`, `.upload(`, `submission-files`), and list the storage buckets in the Supabase project | No storage call exists in either function; the project has no bucket named `submission-files` and no object; `submissions.file_path` is empty on every row and a database check refuses a non-empty value | Claude Code, verifier |

**Screen checks**

| # | Screen | What must be true | Performed by |
|---|--------|-------------------|--------------|
| S1 | Hero | Logo, title, "Submissions close 30 September 2027" lime badge on black, and a Start button that scrolls to section 04 | builder, verifier |
| S2 | 01 Overview | Four figures and six themes with ESRS references; figures stack to one column on a phone | builder, verifier |
| S3 | 02 Why | Three cards and the "Ask once" callout | builder |
| S4 | 03 How it works | Two route cards (Route B says it is submitted on this page, by form or upload) and the four-phase timeline with the right dates | builder, verifier |
| S5 | 04 before any choice | The question and both buttons are visible, and neither path is visible | builder, verifier |
| S6 | 04, press Yes | A Path opens, B Path stays hidden; one line of text above the short entry form (no numbered steps); the form shows with the data notice; an empty required field blocks it; after saving, the form is replaced by "One step left", the line "Share your scorecard with The Corporate on EcoVadis.", "Go to EcoVadis" as the only primary button (it opens EcoVadis in a new tab, nothing opens by itself), and the small saved line with the date and reference | builder |
| S7 | 04, press No | B Path opens, A Path hidden; the workbook downloads and opens in Excel; the two buttons "Fill in the form" and "Upload the filled workbook" show, neither preselected; there is no Return by email | builder |
| S8 | 04, switch routes | Pressing Yes then No (and back) shows only the latest path each time, and switching between the form and the upload shows only the latest panel; a reload returns to the neutral state and clears anything typed | builder |
| S9 | Footer | Contact address, the data line "Data you submit on this page is stored by The Corporate. This page uses no cookies and no tracking.", and a link to About this tool | builder |
| S10 | Brand | Acid Lime appears exactly twice and only on Ink or as the 2px left border; square corners; no shadows or gradients; Playfair headlines and DM Sans body; the new screens follow the brand | builder, verifier |
| S11 | Phone (360px) | No horizontal scroll on any screen including the form, review and confirmation; the timeline stacks; buttons are at least 44px tall | builder |
| S12 | Keyboard | Every control, including form fields, dropdowns, the file chooser, the tick box and every button, is reachable with Tab, shows a focus ring, and works with Enter and Space | builder, verifier |
| S13 | Form | All 30 questions appear in S1 to S7 order with ESRS references, the workbook's own dropdown options, required marks on company, country, contact name and email, and S1-3 prefilled and fixed; the seven number questions show their unit (tCO2e, kg, m3, tonnes, %), open a number keypad on a phone, and refuse letters with the number message; the notes of S2-1, S2-3, S4-1 and S5-1 are labelled with what they ask for; submitting with a required field empty shows an inline message and moves focus to it; "Review your answers" opens the review screen without saving | builder, verifier |
| S14 | Upload and review | The upload panel says the file is not kept; choosing the filled workbook shows the review screen with the answers filled in, editable, and company name and contact email as separate fields to confirm; choosing a workbook with text in a number cell shows the review screen (not an error) with that field marked; choosing a wrong file shows the error message and nothing else happens; the declaration must be completed on screen; "Confirm and submit" stays disabled until the required fields, the tick and every number field are valid | builder, verifier |
| S15 | Confirmation and failure | After confirming, "Submission received" shows the date, the company name and a reference; with the save function turned off, the error "We could not save your submission. Nothing was recorded. Please try again." shows with Try again, the answers are still on screen, and on the A Path the EcoVadis link is still offered | builder, verifier |
| S16 | About this tool | Reached from the footer; shows who runs it and the contact, what is stored and about whom (and that an uploaded workbook is not kept), where it is processed, how long it is kept, how to ask for deletion, no login, no cookies, and version 2.1 | builder |

**Refusal checks**

| # | Reference | Performed by |
|---|-----------|--------------|
| R1 | Every `no` cell in `docs/access-matrix.md` (written by the Access Architect's short run): the browser, with no key or the publishable key, can read, create, change or delete nothing in either table, and finds no bucket. This is checked through the API (D16 is its data form) and from the supplier's side: after confirming, a supplier cannot see, fetch or list their own submission. | Claude Code (through the API), builder (from the Deploy Preview) |

---

## Section 14: Build Path

**This tool's tier:** Tier 2

### Pre-build steps (all in Claude Code, in this repo, in this session)

- [x] GitHub repo reused (`ZHatquai/supplier-portal-cohort-3`), open in Claude Code, on the branch of pull request 4
- [x] The change, in the builder's own words, saved as `intent-2026-11-20.md`
- [x] Tool Architect, Iteration Mode: delta interview complete, this spec (v2.1) written and confirmed by the builder
- [ ] Access Architect, short run: `access-matrix.md` and `user-stories.md` revised against v2.1 (no bucket, no file; the write-only rules unchanged)
- [ ] Project Governor, Iteration Mode: CLAUDE.md, PROGRESS.md and `docs/checks.md` updated from this spec and the matrix; the rules v2.1 overrides (Section 1) are rewritten, not appended
- [x] Brand skill (`the-corporate-brand`) already in the repo
- [x] Supabase project exists and is connected to the Netlify site (keys start with `sb_`)

### Tier 2: build session (v2.1, same session)

- [ ] Claude Code states the lane (change, v2.1 governed), proposes the plan, the builder approves, the plan goes into PROGRESS.md
- [ ] Claude Code deletes the builder's test rows (SustainOS test 1, Test B) and their answer rows; they are test data, so no export is needed
- [ ] The builder deletes the three test files and then the bucket `submission-files` on the Supabase Storage page (Supabase refuses SQL deletes of stored files)
- [ ] Claude Code applies one named migration, saved in `supabase/migrations/`: `file_path` always empty (a check constraint), `create_submission` no longer writes `file_path`; nothing dropped or renamed. `docs/supabase-setup.md` updated in the same save point
- [ ] Claude Code changes `submit` (no file, no storage call, 300 KB limit, the number rule) and the page (A Path text and confirmation, number fields with units and note labels, upload review marking, upload note, About page), and adds the fixture `workbook_text_in_numbers.xlsx`
- [ ] Claude Code runs the data and screen checks it can, pastes the results into PROGRESS.md, runs the verifier
- [ ] Claude Code pushes the branch (confirmed on GitHub); pull request 4 carries it; Netlify rebuilds the Deploy Preview; the builder says *checks* and does the builder rows on the preview
- [ ] Claude Code runs the reviewer on the branch; blockers fixed; the builder merges on GitHub and deletes the branch; main deploys
- [ ] Before the first supplier wave: the builder switches Supabase from Free to Pro, and decides on the bot check (Section 15)

---

## Section 15: Open Questions

| Question | Who answers it | Blocking? |
|----------|---------------|-----------|
| **Known risk, public form without a bot check.** This is a public form: anyone with the link can send it, and so can a bot. While you are testing with your own entries, that is fine. Before you share it beyond testing, add a bot check. That means a free Cloudflare account, a Turnstile widget for your site's address, two keys in Netlify (the site key for the form, the secret key for the submit function), and a check in the submit function. About 15 minutes. Ask me when you are ready and I will add it. | Builder, before sharing beyond testing | No, can resolve after the build |
| Who is the first person to read the later dashboard (name and work email)? | Builder | No, needed only when the dashboard is specced |
| Does The Corporate's privacy contact sign off the data notice, the lawful basis (contract or legitimate interest) and the retention "until deleted on request"? They may require a fixed retention period. | Builder, with the privacy contact | Yes, before launch (not before build) |
| Who in The Corporate's team passes deletion requests to the platform owner, and who is the platform owner after the page moves to a company account? | Builder | No, before launch |
| Does Procurement or EHS and Sustainability sign off the page before it goes to suppliers? | Builder | Yes, before launch (not before build) |
| Is `https://ecovadis.com` the page the A Path button should open, or is there a customer-specific EcoVadis link or step for sharing a scorecard with The Corporate? Since v2.1 this button is the A Path's single next step. | Builder | Yes, before launch (not before build) |
| Public URLs for the Supplier Code of Conduct and the Global Environmental Policy (to link from section 01) | Builder | No, added by iteration |
| Is the questionnaire workbook final for the 2027 cycle (its title and file name say 2026)? The upload reader depends on the workbook's layout: if the workbook is swapped for one with different rows, the reader's expected rows must be updated in the same change. | Builder | Yes for the upload reader: confirm before the build that this layout is the one suppliers will use |
| Until the dashboard exists, the builder reads submissions in the Supabase dashboard (no files exist since v2.1). Is that acceptable for the first supplier wave? | Builder | No |

---

## Section 16: Tool Version History

| Version | Date | What changed in the tool |
|---------|------|--------------------------|
| v1.0 | 9 November 2026 | Initial build |
| v2.0 | 16 November 2026 | Submission through the tool: an on-page form mirroring the 30-question workbook, upload of the filled workbook with the answers read out and reviewed by the supplier before saving, a short record on the EcoVadis path, a Supabase database and private file storage, the data notice and the About page. Return by email removed. The tier changes from Tier 1 to Tier 2. The dashboard is deferred. |
| v2.1 | 20 November 2026 | After the builder's test of v2.0 on the Deploy Preview: the A Path confirmation is one next step ("One step left", Go to EcoVadis as the single action) with one line of text before the form; the seven Quantitative questions accept a number only, with their unit, on the page and in the submit function, and an upload with text in a number cell is marked for correction on the review screen instead of refused; an uploaded workbook is read and never stored (no file storage, the bucket removed, `file_path` always empty); the supersede rule is unchanged. Same tier and access model. |

---

*This spec is written for Claude Code. It assumes zero prior context.*
