# User Stories: Supplier Sustainability Portal

**Written against:** product-spec.md v2.0 · supabase-setup.md not yet created (short run)
**Date:** 16 November 2026
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
  Acceptance: a visitor presses Yes, enters company name, contact name and email, presses Save and continue; the page sends it to the `submit` function; one `submissions` row exists with route `ecovadis`, status `received` and no answer rows; the confirmation shows the date.
- **As a visitor, I submit the completed questionnaire through the form, so that The Corporate receives my answers.** `[submissions · create · anon]`
  Acceptance: a visitor fills the form, reviews, confirms; the function validates every field; one `submissions` row exists with route `form` and status `received`.
- **As a visitor, I submit the answers of the questionnaire, so that each answer is stored with its question.** `[submission_answers · create · anon]`
  Acceptance: after the same confirmation, 30 `submission_answers` rows exist for that submission, one per question id.
- **As a visitor, I upload the filled workbook and confirm, so that my file is kept with my answers.** `[submissions · create · anon]`
  Acceptance: a visitor uploads the workbook, reviews the extracted answers, confirms; one `submissions` row exists with route `upload`, and the file sits in the private bucket under that submission's id.
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
- **As a visitor, I cannot fetch or list uploaded files, mine included.** `[submission-files · read · anon]` (= no)
  Acceptance: fetching a file by URL without the platform owner's session is refused; listing the bucket is refused.
- **As a visitor, I cannot upload a file directly to storage, so that only confirmed files exist.** `[submission-files · upload · anon]` (= no)
  Acceptance: an upload to the bucket from the browser or the API is refused; a file exists only after the function stored it on a confirmed submission.

### platform owner: the Supabase dashboard

- **As the platform owner, I read submissions and open files in the Supabase dashboard until the dashboard exists, so that the programme team can work.**
  Acceptance: Zyad Hatquai opens the project, sees the rows of both tables and opens an uploaded file. This is outside the app and outside the matrix; it is the only reading path in this build.

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
| 6 | a logged-out visitor | list or fetch a file in the bucket | refused | submission-files · read · anon |
| 7 | a logged-out visitor | upload to the bucket directly | refused | submission-files · upload · anon |
| 8 | a logged-out visitor | export submissions | nothing to export; no read exists | submissions · export · anon |

---

## Later list (not this version)

- The dashboard for The Corporate's team, with its login, a reading role and a named first reader (spec Section 12). The full run of the Access Architect writes that matrix against the real tables.
- Withdraw, reinstate and anonymise as narrow admin functions, when an admin exists. Until then the platform owner handles a GDPR deletion request in the Supabase dashboard (matrix Section 7, rule 4).
- A bot check on the public form (spec Section 15).
