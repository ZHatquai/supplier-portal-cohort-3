# Checks: Supplier Sustainability Portal

Written against product-spec.md v1.0 · 9 November 2026 · by Project Governor

> What "done" means for this tool. Claude Code runs the rows it can perform at the end of every phase and writes the result and date in the last column; the verifier agent re-runs them in a fresh context; the builder performs the rows marked "builder" on the Deploy Preview before merging. A row that fails is fixed in the tool, never in this file. This file changes only when the spec changes (through the Project Governor); Claude Code never edits a row.

## Data checks
Known input in, known result out. This tool has no database, so these run against the built site and the repo.

| # | Given (fixture or action) | Expected result | Performed by | Last result |
|---|---------------------------|-----------------|--------------|-------------|
| D1 | The built site's `/downloads/` file compared with `reference/The_Corporate_Supplier_Questionnaire_2026_39.xlsx` | Identical bytes (checksum match). The file opens and its sheet "Supplier Assessment 2026" has 7 sections, S1 to S7. | Claude Code, verifier | PASS 9 November 2026 (Claude Code) |
| D2 | The "Return by email" link in the built HTML | `href` starts with `mailto:inbox@thecorporate.com`, contains a subject, and has no other recipient | Claude Code, verifier | PASS 9 November 2026 (Claude Code) |
| D3 | The "Go to EcoVadis" link in the built HTML | `href` is `https://ecovadis.com`, `target="_blank"`, `rel` contains `noopener` | Claude Code, verifier | PASS 9 November 2026 (Claude Code) |
| D4 | Search the built output and the repo for `ecovadis`, `inbox@`, `api_key`, `secret`, `token`, `eyJ`, and for the strings `690,000`, `RACI`, `15 business days`, `escalat` | The two intended links appear. No credential string appears. None of the four internal-only terms appears in any page text. | Claude Code, verifier | PASS 9 November 2026 (Claude Code) |
| D5 | Timeline text | Shows April 2027, 30 September 2027, Q4 2027 and Q1 2028, and no 2026 date | Claude Code, verifier | PASS 9 November 2026 (Claude Code) |
| D6 | The four figures | 71%, 500+, 2045 and 50% appear, and no other tCO2e figure appears | Claude Code, verifier | PASS 9 November 2026 (Claude Code) |
| D7 | `netlify.toml` and the deployed folder | `publish = "site"` with no build command; the site folder holds only index.html, css, js, assets and downloads, so nothing under docs/, reference/ or .claude/ is served | Claude Code, verifier | PASS 9 November 2026 (Claude Code) |

## Screen checks
What must be visible and what must happen. The builder does these on the Deploy Preview; the verifier does the ones it can see.

| # | Screen | What must be true | Performed by | Last result |
|---|--------|-------------------|--------------|-------------|
| S1 | Hero | Logo, title, "Submissions close 30 September 2027" lime badge on black, and a Start button that scrolls to section 04 | builder, verifier | |
| S2 | 01 Overview | Four figures and six themes with ESRS references; figures stack to one column on a phone | builder, verifier | |
| S3 | 02 Why | Three cards and the "Ask once" callout | builder | |
| S4 | 03 How it works | Two route cards and the four-phase timeline with the right dates | builder, verifier | |
| S5 | 04 before any choice | The question and both buttons are visible, and neither path is visible | builder, verifier | |
| S6 | 04, press Yes | A Path opens, B Path stays hidden, "Go to EcoVadis" opens EcoVadis in a new tab | builder | |
| S7 | 04, press No | B Path opens, A Path hidden, the file downloads and opens in Excel, the email button opens a draft to inbox@thecorporate.com with the subject filled | builder | |
| S8 | 04, switch routes | Pressing Yes then No (and back) shows only the latest path each time; a reload returns to the neutral state | builder | |
| S9 | Footer | Contact address and the line "This page does not collect or store any information about you." | builder | |
| S10 | Brand | Acid Lime appears exactly twice and only on Ink or as the 2px left border; square corners; no shadows or gradients; Playfair headlines and DM Sans body | builder, verifier | |
| S11 | Phone (360px) | No horizontal scroll; the timeline stacks; buttons are at least 44px tall | builder | |
| S12 | Keyboard | Every control is reachable with Tab, shows a focus ring, and the question buttons work with Enter and Space | builder, verifier | |

## Refusal checks
Not applicable: no database, no login.

## How a result is written
`PASS 2026-11-16 (Claude Code)` · `PASS 2026-11-16 (verifier)` · `PASS 2026-11-17 (builder, branch address)` · `FAIL 2026-11-16 (verifier): [one line why]`. A FAIL stays until the row passes again; the earlier FAIL is kept in PROGRESS.md Check results, not here.
