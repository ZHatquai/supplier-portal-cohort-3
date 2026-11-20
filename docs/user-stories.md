# User Stories: Supplier Sustainability Portal

**Written against:** product-spec.md v2.1 · supabase-setup.md as of 16 November 2026 (short run, revised for v2.1)
**Date:** 20 November 2026
**Author:** Zyad Hatquai
**Status:** Confirmed
**Population pattern:** P1 public, stays anonymous (as in access-matrix.md)
**Companion file:** access-matrix.md (every story below cites exactly one cell of it: `[table · action · role]`, one of the seven actions; a story that needs two cells is two stories)

> Read by the Project Governor (Iteration Mode) and by Claude Code when it builds the database. Each acceptance line is a screen test or an API test. Stories whose cell is `no` are refusal tests and are as important as the others.

---

## The people

| Role | Named first holder | Layer | Opens |
|---|---|---|---|
| anon, the public visitor | no name | outside the app | the page: the A Path short entry, the form, the upload, the review and confirm screen |
| platform owner | Zyad Hatquai (account email domain not recorded here) | outside the app | Supabase and Netlify dashboards |

Nobody logs in. The full run adds the named dashboard reader when the dashboard is specced.

---

## Stories by role and screen

### anon: the page (section 04)

- **As a visitor, I record a short entry on the EcoVadis route, so that The Corporate knows which suppliers hold a scorecard.** `[submissions · create · anon]`
  Acceptance: a visitor presses Yes, enters company name, contact name and email, presses Save and continue; the page sends it to the `submit` function; one `submissions` row exists with route `ecovadis`, status `received` and no answer rows; the confirmation reads "One step left" with Go to EcoVadis as the single action and the saved date.
- **As a visitor, I submit the completed questionnaire through the form, so that The Corporate receives my answers.** `[submissions · create · anon]`
  Acceptance: a visitor fills the form, reviews, confirms; the function validates every field; one `submissions` row exists with route `form` and status `received`.
- **As a visitor, I submit the answers of the questionnaire, so that each answer is stored with its question.** `[submission_answers · create · anon]`
  Acceptance: after the same confirmation, 30 `submission_answers` rows exist for that submission, one per question id.
- **As a visitor, I upload the filled workbook, check the answers it fills in and confirm, so that my confirmed answers are submitted without retyping them.** `[submissions · create · anon]`
  Acceptance: a visitor uploads the workbook, reviews and corrects the extracted answers, confirms; one `submissions` row exists with route `upload` and `file_path` empty, and no file exists in Supabase storage.
- **As a visitor, I submit again with the same company name and contact email, so that my newer submission replaces the older one.** `[submissions · change state · anon]` (= no for the visitor; the function does it)
  Acceptance: a visitor confirms a second submission with the same company name and email; the earlier row becomes `superseded` and the new row is `received`; the visitor never asked for the change and has no edit screen.
- **As a visitor, I cannot read any submission, mine included, so that nothing leaks.** `[submissions · read · anon]` (= no)
  Acceptance: a direct read from the browser or the API returns a permission error, not an empty list; no screen shows a stored record.
- **As a visitor, I cannot read any answer, so that nothing leaks.** `[submission_answers · read · anon]` (= no)
  Acceptance: a direct read of the answers returns a permission error.
- **As a visitor, I cannot edit a submission; I submit again instead.** `[submissions · update · anon]` (= no)
  Acceptance: no edit screen exists; a direct update from the browser or the API is refused.
- **As a visitor, I cannot delete a submission.** `[submissions · delete · anon]` (= no)
  Acceptance: no delete works from any account through the API.
- **As a visitor, I cannot get a file stored, so that no workbook (and the personal data in it) is kept.** `[storage · any · everyone]` (= no; no bucket exists)
  Acceptance: listing buckets with the publishable key or no key finds nothing; a request to `submit` that carries a file is refused and saves nothing.

### platform owner: the Supabase dashboard

- **As the platform owner, I read submissions in the Supabase dashboard until the dashboard exists, so that the programme team can work.**
  Acceptance: Zyad Hatquai opens the project and sees the rows of both tables. This is outside the app and outside the matrix; it is the only reading path in this build.

---

## Stories that are refusals (collected)

The test list, one line per `no` in the matrix.

| # | Who | Tries | Result | Cell |
|---|---|---|---|---|
| 1 | a logged-out visitor | read any submission through the browser or the API | permission error | submissions · read · anon |
| 2 | a logged-out visitor | read any answer | permission error | submission_answers · read · anon |
| 3 | a logged-out visitor | insert a row directly with the publishable key | refused; only the function writes | submissions · create · anon (direct) |
| 4 | a logged-out visitor | update a submission | refused | submissions · update · anon |
| 5 | a logged-out visitor | delete a submission | refused | submissions · delete · anon |
| 6 | a logged-out visitor | list buckets, or send a file to `submit` | nothing found; the file request is refused and saves nothing | storage · any · everyone |
| 7 | a logged-out visitor | export submissions | nothing to export; no read exists | submissions · export · anon |

---

## Later list (not this version)

- The dashboard for The Corporate's team, with its login, a reading role and a named first reader (spec Section 12). The full run of the Access Architect writes that matrix against the real tables.
- Withdraw, reinstate and anonymise as narrow admin functions, when an admin exists. Until then the platform owner handles a GDPR deletion request in the Supabase dashboard (matrix Section 7, rule 4).
- A bot check on the public form (spec Section 15).
