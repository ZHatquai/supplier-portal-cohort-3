-- seed-wave1-28.sql  (version 3, adjusted to the v2.1 number rule)
-- Loaded into the live project on 23 November 2026 (session 5) through the Supabase connector.
-- v2.1 change from version 2: nine S5-1 answers held text ("322 total (landfill 81, ...)"); submit now refuses text
-- in a number field, so the number stays in response and the breakdown moved to evidence_note
-- ("Breakdown and notes", the v2.1 label). Nothing else changed.
-- Wave 1 seed for the Cohort 3 supplier portal (Week 4, "Design the dashboard").
-- Source: wave1_mock_db_inserts_2026.xlsx (sheets w4_suppliers, w4_submissions).
-- Schema: supabase/migrations/20261116155335_initial_schema.sql on branch claude/affectionate-ptolemy-udznhn,
--         and the live project huahhrvlvkqktvvimylo (read 19 Nov 2026). Mirrors what create_submission() and
--         netlify/lib/validate.js write: 30 answer rows per form submission, empty answers as null,
--         S1-1 / S1-2 composed from the confirmed fields, S1-3 fixed to the form's own "No" option,
--         company_key = lower-cased name with single spaces + '|' + lower-cased email.
-- Tested 19 Nov 2026 on a local Postgres 16 loaded with that migration: runs clean, counts below, delete block empties it.
--
-- DO NOT RUN before the Week 3 Friday session on 20 Nov (the session needs an empty table).
-- Run only on Zyad's go: in the Supabase SQL editor, in a Claude Code session on the repo, or through the Supabase connector.
-- The SQL editor and the service role bypass RLS. No rule, grant or policy changes.
--
-- Recognisable: every contact email ends in @example.com; every EcoVadis link is on ecovadis.example.com.
-- Removable: the delete block is at the end of this file, commented out.
-- Dates: created_at keeps the submission dates from the workbook (June and July 2026).
--
-- EXPECTED COUNTS AFTER RUNNING (on top of whatever is already in the tables)
--   submissions with @example.com:  28
--     route 'ecovadis':             17
--     route 'form':                 11
--     status 'received':            28
--   submission_answers:             330  (30 per form submission; 31 of them have an empty response, as the form stores them)
--
-- Check with:
--   select route, status, count(*) from submissions where contact_email like '%@example.com' group by 1, 2;
--   select count(*), count(response) from submission_answers a join submissions s on s.id = a.submission_id
--     where s.contact_email like '%@example.com';

begin;

-- 1. The 17 EcoVadis-route submissions: company, contact, scorecard link. No score is stored; no declaration needed.
insert into public.submissions (id, route, company_name, company_country, contact_name, contact_title, contact_email, ecovadis_link, declaration_name, declaration_date, declaration_confirmed, company_key, status, created_at, updated_at)
values
  ('bd208237-dec7-4596-955a-be5628b03c0e', 'ecovadis', 'Strata Power Co. Ltd.', null, 'Tuan Pham', null, 'tuan.pham.stratapower@example.com', 'https://ecovadis.example.com/scorecard/TC-SUP-0166', null, null, false, 'strata power co. ltd.|tuan.pham.stratapower@example.com', 'received', '2026-06-01T09:00:00Z', '2026-06-01T09:00:00Z'),
  ('e50fdce9-94ea-4592-98e0-c82a75821c70', 'ecovadis', 'Global Precision Co. Ltd.', null, 'Tuan Tran', null, 'tuan.tran.globalprecision@example.com', 'https://ecovadis.example.com/scorecard/TC-SUP-0189', null, null, false, 'global precision co. ltd.|tuan.tran.globalprecision@example.com', 'received', '2026-06-02T09:00:00Z', '2026-06-02T09:00:00Z'),
  ('e2399bc7-09a5-46ec-ac08-fa51b2cef25b', 'ecovadis', 'Advanced Logistics Sp. z o.o.', null, 'Anna Kowalski', null, 'anna.kowalski.advancedlogistics@example.com', 'https://ecovadis.example.com/scorecard/TC-SUP-0321', null, null, false, 'advanced logistics sp. z o.o.|anna.kowalski.advancedlogistics@example.com', 'received', '2026-06-03T09:00:00Z', '2026-06-03T09:00:00Z'),
  ('07afe2ab-685c-41ca-89e3-b373b3b86d44', 'ecovadis', 'Global Components Co. Ltd.', null, 'Wei Liu', null, 'wei.liu.globalcomponents@example.com', 'https://ecovadis.example.com/scorecard/TC-SUP-0457', null, null, false, 'global components co. ltd.|wei.liu.globalcomponents@example.com', 'received', '2026-06-03T09:00:00Z', '2026-06-03T09:00:00Z'),
  ('572b6fff-7f4d-41b1-8222-4f1c19fab4e0', 'ecovadis', 'Nova Power PT', null, 'Sari Kusuma', null, 'sari.kusuma.novapower@example.com', 'https://ecovadis.example.com/scorecard/TC-SUP-0123', null, null, false, 'nova power pt|sari.kusuma.novapower@example.com', 'received', '2026-06-04T09:00:00Z', '2026-06-04T09:00:00Z'),
  ('1c5441de-b472-448d-9d5a-43962af7eaf8', 'ecovadis', 'Alpha Components Co. Ltd.', null, 'Wei Wu', null, 'wei.wu.alphacomponents@example.com', 'https://ecovadis.example.com/scorecard/TC-SUP-0175', null, null, false, 'alpha components co. ltd.|wei.wu.alphacomponents@example.com', 'received', '2026-06-04T09:00:00Z', '2026-06-04T09:00:00Z'),
  ('45badd3e-7e4a-4d2c-afc9-3f91e1574d18', 'ecovadis', 'Omni Materials Co. Ltd.', null, 'Lan Tran', null, 'lan.tran.omnimaterials@example.com', 'https://ecovadis.example.com/scorecard/TC-SUP-0065', null, null, false, 'omni materials co. ltd.|lan.tran.omnimaterials@example.com', 'received', '2026-06-05T09:00:00Z', '2026-06-05T09:00:00Z'),
  ('28d37819-c37e-47bc-abbd-851d6fbca9a8', 'ecovadis', 'Advanced Dynamics Pvt. Ltd.', null, 'Sneha Sharma', null, 'sneha.sharma.advanceddynamics@example.com', 'https://ecovadis.example.com/scorecard/TC-SUP-0363', null, null, false, 'advanced dynamics pvt. ltd.|sneha.sharma.advanceddynamics@example.com', 'received', '2026-06-05T09:00:00Z', '2026-06-05T09:00:00Z'),
  ('ef547910-a1b1-429b-9be4-fc045ce0806e', 'ecovadis', 'Beta Power S.A. de C.V.', null, 'Alejandro Garcia', null, 'alejandro.garcia.betapower@example.com', 'https://ecovadis.example.com/scorecard/TC-SUP-0307', null, null, false, 'beta power s.a. de c.v.|alejandro.garcia.betapower@example.com', 'received', '2026-06-06T09:00:00Z', '2026-06-06T09:00:00Z'),
  ('b3164b30-2e14-49f0-b0a2-44d68a6c0709', 'ecovadis', 'Global Logistics Pvt. Ltd.', null, 'Priya Sharma', null, 'priya.sharma.globallogistics@example.com', 'https://ecovadis.example.com/scorecard/TC-SUP-0326', null, null, false, 'global logistics pvt. ltd.|priya.sharma.globallogistics@example.com', 'received', '2026-06-06T09:00:00Z', '2026-06-06T09:00:00Z'),
  ('8472da4d-16a3-479b-bafc-b7fb592e8ed1', 'ecovadis', 'Prime Precision Pvt. Ltd.', null, 'Sneha Patel', null, 'sneha.patel.primeprecision@example.com', 'https://ecovadis.example.com/scorecard/TC-SUP-0040', null, null, false, 'prime precision pvt. ltd.|sneha.patel.primeprecision@example.com', 'received', '2026-06-07T09:00:00Z', '2026-06-07T09:00:00Z'),
  ('04427e1c-cd4c-4a47-b4c6-0ab970afcfc3', 'ecovadis', 'Advanced Logistics Co. Ltd.', null, 'Malee Wong', null, 'malee.wong.advancedlogistics@example.com', 'https://ecovadis.example.com/scorecard/TC-SUP-0063', null, null, false, 'advanced logistics co. ltd.|malee.wong.advancedlogistics@example.com', 'received', '2026-06-09T09:00:00Z', '2026-06-09T09:00:00Z'),
  ('f2a3f0c6-35a0-4fb9-ac9a-d9333f7a32f1', 'ecovadis', 'Advanced Materials S.A.', null, 'Matias Diaz', null, 'matias.diaz.advancedmaterials@example.com', 'https://ecovadis.example.com/scorecard/TC-SUP-0460', null, null, false, 'advanced materials s.a.|matias.diaz.advancedmaterials@example.com', 'received', '2026-06-09T09:00:00Z', '2026-06-09T09:00:00Z'),
  ('84354a9f-2fe7-440f-981b-500dbc0adb09', 'ecovadis', 'Electro Power Sdn. Bhd.', null, 'Ahmad Tan', null, 'ahmad.tan.electropower@example.com', 'https://ecovadis.example.com/scorecard/TC-SUP-0442', null, null, false, 'electro power sdn. bhd.|ahmad.tan.electropower@example.com', 'received', '2026-06-10T09:00:00Z', '2026-06-10T09:00:00Z'),
  ('d0a8d98e-b938-4ce2-bdee-d4aa15f2179d', 'ecovadis', 'Strata Components S.A. de C.V.', null, 'Maria Lopez', null, 'maria.lopez.stratacomponents@example.com', 'https://ecovadis.example.com/scorecard/TC-SUP-0456', null, null, false, 'strata components s.a. de c.v.|maria.lopez.stratacomponents@example.com', 'received', '2026-06-11T09:00:00Z', '2026-06-11T09:00:00Z'),
  ('b81d826c-3ac6-4ab9-9daf-f7e1c4dece2c', 'ecovadis', 'Nexus Components s.r.o.', null, 'Jan Novak', null, 'jan.novak.nexuscomponents@example.com', 'https://ecovadis.example.com/scorecard/TC-SUP-0470', null, null, false, 'nexus components s.r.o.|jan.novak.nexuscomponents@example.com', 'received', '2026-06-12T09:00:00Z', '2026-06-12T09:00:00Z'),
  ('820aabb1-487d-40a3-ae10-93ed8be31857', 'ecovadis', 'Pinnacle Chemicals Sdn. Bhd.', null, 'Siti Tan', null, 'siti.tan.pinnaclechemicals@example.com', 'https://ecovadis.example.com/scorecard/TC-SUP-0179', null, null, false, 'pinnacle chemicals sdn. bhd.|siti.tan.pinnaclechemicals@example.com', 'received', '2026-06-13T09:00:00Z', '2026-06-13T09:00:00Z');

-- 2. The 11 questionnaire-route submissions (route 'form'; all carry the declaration the constraint requires).
insert into public.submissions (id, route, company_name, company_country, contact_name, contact_title, contact_email, ecovadis_link, declaration_name, declaration_date, declaration_confirmed, company_key, status, created_at, updated_at)
values
  ('607a321f-563b-4fb6-aa89-b6b5be2760cf', 'form', 'Advanced Precision s.r.o.', 'Czechia', 'Petra Dvorak', 'ESG Coordinator', 'petra.dvorak.advancedprecision@example.com', null, 'Petra Dvorak', '2026-06-11', true, 'advanced precision s.r.o.|petra.dvorak.advancedprecision@example.com', 'received', '2026-06-11T14:30:00Z', '2026-06-11T14:30:00Z'),
  ('1041d63b-6a97-49c9-95d6-d75e86eacbc0', 'form', 'Nexus Chemicals GmbH', 'Germany', 'Michael Muller', 'ESG Coordinator', 'michael.muller.nexuschemicals@example.com', null, 'Michael Muller', '2026-06-16', true, 'nexus chemicals gmbh|michael.muller.nexuschemicals@example.com', 'received', '2026-06-16T14:30:00Z', '2026-06-16T14:30:00Z'),
  ('1712138a-c8a6-47e6-97db-7617baf11f84', 'form', 'Alpha Materials S.A. de C.V.', 'Mexico', 'Alejandro Garcia', 'ESG Coordinator', 'alejandro.garcia.alphamaterials@example.com', null, 'Alejandro Garcia', '2026-06-17', true, 'alpha materials s.a. de c.v.|alejandro.garcia.alphamaterials@example.com', 'received', '2026-06-17T14:30:00Z', '2026-06-17T14:30:00Z'),
  ('bcf3b126-e05a-45f5-8760-5d134e17fc7f', 'form', 'Quantum Materials Sdn. Bhd.', 'Malaysia', 'Wei Lee', 'ESG Coordinator', 'wei.lee.quantummaterials@example.com', null, 'Wei Lee', '2026-06-19', true, 'quantum materials sdn. bhd.|wei.lee.quantummaterials@example.com', 'received', '2026-06-19T14:30:00Z', '2026-06-19T14:30:00Z'),
  ('a5f83550-005c-41df-9c93-2a849ce84801', 'form', 'Global Materials Pvt. Ltd.', 'India', 'Sneha Singh', 'ESG Coordinator', 'sneha.singh.globalmaterials@example.com', null, 'Sneha Singh', '2026-06-20', true, 'global materials pvt. ltd.|sneha.singh.globalmaterials@example.com', 'received', '2026-06-20T14:30:00Z', '2026-06-20T14:30:00Z'),
  ('3c11c753-7ce7-4f36-aba2-914faa9d0a9d', 'form', 'Tech Precision Co. Ltd.', 'China', 'Jing Li', 'ESG Coordinator', 'jing.li.techprecision@example.com', null, 'Jing Li', '2026-06-20', true, 'tech precision co. ltd.|jing.li.techprecision@example.com', 'received', '2026-06-20T14:30:00Z', '2026-06-20T14:30:00Z'),
  ('2acf39ba-4ccb-47d2-be6b-2e80a0ab2982', 'form', 'Pinnacle Power Co. Ltd.', 'Vietnam', 'Tuan Nguyen', 'ESG Coordinator', 'tuan.nguyen.pinnaclepower@example.com', null, 'Tuan Nguyen', '2026-06-28', true, 'pinnacle power co. ltd.|tuan.nguyen.pinnaclepower@example.com', 'received', '2026-06-28T14:30:00Z', '2026-06-28T14:30:00Z'),
  ('72a4d1eb-00f2-47a0-9264-e4d88b99c2c7', 'form', 'Electro Components Co. Ltd.', 'Taiwan', 'Wei Huang', 'ESG Coordinator', 'wei.huang.electrocomponents@example.com', null, 'Wei Huang', '2026-07-04', true, 'electro components co. ltd.|wei.huang.electrocomponents@example.com', 'received', '2026-07-04T14:30:00Z', '2026-07-04T14:30:00Z'),
  ('2734fc3a-05aa-4c0e-b780-65474fc5f1a6', 'form', 'Global Power Pvt. Ltd.', 'India', 'Sneha Singh', 'ESG Coordinator', 'sneha.singh.globalpower@example.com', null, 'Sneha Singh', '2026-07-05', true, 'global power pvt. ltd.|sneha.singh.globalpower@example.com', 'received', '2026-07-05T14:30:00Z', '2026-07-05T14:30:00Z'),
  ('1e08ddaa-8e12-4dce-9be8-3f9268f86caa', 'form', 'Beta Chemicals Co. Ltd.', 'Taiwan', 'Chien Lin', 'ESG Coordinator', 'chien.lin.betachemicals@example.com', null, 'Chien Lin', '2026-07-05', true, 'beta chemicals co. ltd.|chien.lin.betachemicals@example.com', 'received', '2026-07-05T14:30:00Z', '2026-07-05T14:30:00Z'),
  ('e8e3f826-183b-4473-b3cc-f8d901f41208', 'form', 'Nova Components s.r.o.', 'Czechia', 'Petra Novak', 'ESG Coordinator', 'petra.novak.novacomponents@example.com', null, 'Petra Novak', '2026-07-06', true, 'nova components s.r.o.|petra.novak.novacomponents@example.com', 'received', '2026-07-06T14:30:00Z', '2026-07-06T14:30:00Z');

-- 3. Their answers: 30 rows each, S1-1 to S7-5. evidence_note carries the workbook's extra detail
--    (Scope 1 verification, Scope 3 categories, water source).
insert into public.submission_answers (submission_id, question_id, response, evidence_note, created_at, updated_at)
values
  ('a5f83550-005c-41df-9c93-2a849ce84801', 'S1-1', 'Global Materials Pvt. Ltd., India', null, '2026-06-20T14:30:00Z', '2026-06-20T14:30:00Z'),
  ('a5f83550-005c-41df-9c93-2a849ce84801', 'S1-2', 'Sneha Singh, ESG Coordinator, sneha.singh.globalmaterials@example.com', null, '2026-06-20T14:30:00Z', '2026-06-20T14:30:00Z'),
  ('a5f83550-005c-41df-9c93-2a849ce84801', 'S1-3', 'No — Will Complete Questionnaire', null, '2026-06-20T14:30:00Z', '2026-06-20T14:30:00Z'),
  ('a5f83550-005c-41df-9c93-2a849ce84801', 'S1-4', null, null, '2026-06-20T14:30:00Z', '2026-06-20T14:30:00Z'),
  ('a5f83550-005c-41df-9c93-2a849ce84801', 'S2-1', '20188', 'Internal calculation, GHG Protocol', '2026-06-20T14:30:00Z', '2026-06-20T14:30:00Z'),
  ('a5f83550-005c-41df-9c93-2a849ce84801', 'S2-2', '11584', null, '2026-06-20T14:30:00Z', '2026-06-20T14:30:00Z'),
  ('a5f83550-005c-41df-9c93-2a849ce84801', 'S2-3', '157004', 'Cat 1,3,4,5,6,7', '2026-06-20T14:30:00Z', '2026-06-20T14:30:00Z'),
  ('a5f83550-005c-41df-9c93-2a849ce84801', 'S2-4', 'No', null, '2026-06-20T14:30:00Z', '2026-06-20T14:30:00Z'),
  ('a5f83550-005c-41df-9c93-2a849ce84801', 'S2-5', '1) On-site solar feasibility study underway (21% renewable share today). 2) Compressed air leak programme, est. 400 tCO2e/yr. 3) LED retrofit completed 2025.', null, '2026-06-20T14:30:00Z', '2026-06-20T14:30:00Z'),
  ('a5f83550-005c-41df-9c93-2a849ce84801', 'S2-6', 'Capex competition with capacity expansion; limited access to green financing; renewable tariffs not yet available at our grid location.', null, '2026-06-20T14:30:00Z', '2026-06-20T14:30:00Z'),
  ('a5f83550-005c-41df-9c93-2a849ce84801', 'S3-1', '40350', null, '2026-06-20T14:30:00Z', '2026-06-20T14:30:00Z'),
  ('a5f83550-005c-41df-9c93-2a849ce84801', 'S3-2', 'No', null, '2026-06-20T14:30:00Z', '2026-06-20T14:30:00Z'),
  ('a5f83550-005c-41df-9c93-2a849ce84801', 'S3-3', null, null, '2026-06-20T14:30:00Z', '2026-06-20T14:30:00Z'),
  ('a5f83550-005c-41df-9c93-2a849ce84801', 'S3-4', 'Primary treatment on site, discharge to municipal treatment under permit. Quarterly third-party sampling for heavy metals and COD.', null, '2026-06-20T14:30:00Z', '2026-06-20T14:30:00Z'),
  ('a5f83550-005c-41df-9c93-2a849ce84801', 'S4-1', '82964', 'Municipal', '2026-06-20T14:30:00Z', '2026-06-20T14:30:00Z'),
  ('a5f83550-005c-41df-9c93-2a849ce84801', 'S4-2', 'No', null, '2026-06-20T14:30:00Z', '2026-06-20T14:30:00Z'),
  ('a5f83550-005c-41df-9c93-2a849ce84801', 'S4-3', 'Cooling tower blowdown recovery installed 2025. Intensity roughly flat over three years; metering upgraded in 2024.', null, '2026-06-20T14:30:00Z', '2026-06-20T14:30:00Z'),
  ('a5f83550-005c-41df-9c93-2a849ce84801', 'S4-4', null, null, '2026-06-20T14:30:00Z', '2026-06-20T14:30:00Z'),
  ('a5f83550-005c-41df-9c93-2a849ce84801', 'S5-1', '322', 'Breakdown: landfill 81, recycled 202, energy recovery 32, hazardous 29.', '2026-06-20T14:30:00Z', '2026-06-20T14:30:00Z'),
  ('a5f83550-005c-41df-9c93-2a849ce84801', 'S5-2', '22', null, '2026-06-20T14:30:00Z', '2026-06-20T14:30:00Z'),
  ('a5f83550-005c-41df-9c93-2a849ce84801', 'S5-3', 'Increasing PCR share in housings; regrind of internal scrap into non-cosmetic parts.', null, '2026-06-20T14:30:00Z', '2026-06-20T14:30:00Z'),
  ('a5f83550-005c-41df-9c93-2a849ce84801', 'S5-4', 'Diversion around 70%. Main streams: mixed plastics and packaging to recycling; hazardous sludge to licensed treatment. Evaluating waste-to-energy for residuals.', null, '2026-06-20T14:30:00Z', '2026-06-20T14:30:00Z'),
  ('a5f83550-005c-41df-9c93-2a849ce84801', 'S6-1', 'No', null, '2026-06-20T14:30:00Z', '2026-06-20T14:30:00Z'),
  ('a5f83550-005c-41df-9c93-2a849ce84801', 'S6-2', 'Landscaping with native species; light curfew on non-production areas.', null, '2026-06-20T14:30:00Z', '2026-06-20T14:30:00Z'),
  ('a5f83550-005c-41df-9c93-2a849ce84801', 'S6-3', 'No. Target date: Q4 2027.', null, '2026-06-20T14:30:00Z', '2026-06-20T14:30:00Z'),
  ('a5f83550-005c-41df-9c93-2a849ce84801', 'S7-1', 'Yes', null, '2026-06-20T14:30:00Z', '2026-06-20T14:30:00Z'),
  ('a5f83550-005c-41df-9c93-2a849ce84801', 'S7-2', 'Yes', null, '2026-06-20T14:30:00Z', '2026-06-20T14:30:00Z'),
  ('a5f83550-005c-41df-9c93-2a849ce84801', 'S7-3', 'Suggestion boxes and HR open-door process. 3 grievances filed, 3 resolved in the last 12 months.', null, '2026-06-20T14:30:00Z', '2026-06-20T14:30:00Z'),
  ('a5f83550-005c-41df-9c93-2a849ce84801', 'S7-4', 'Yes', null, '2026-06-20T14:30:00Z', '2026-06-20T14:30:00Z'),
  ('a5f83550-005c-41df-9c93-2a849ce84801', 'S7-5', 'Code of conduct signed by key suppliers at onboarding; 2 third-party audits in the last 24 months.', null, '2026-06-20T14:30:00Z', '2026-06-20T14:30:00Z'),
  ('2734fc3a-05aa-4c0e-b780-65474fc5f1a6', 'S1-1', 'Global Power Pvt. Ltd., India', null, '2026-07-05T14:30:00Z', '2026-07-05T14:30:00Z'),
  ('2734fc3a-05aa-4c0e-b780-65474fc5f1a6', 'S1-2', 'Sneha Singh, ESG Coordinator, sneha.singh.globalpower@example.com', null, '2026-07-05T14:30:00Z', '2026-07-05T14:30:00Z'),
  ('2734fc3a-05aa-4c0e-b780-65474fc5f1a6', 'S1-3', 'No — Will Complete Questionnaire', null, '2026-07-05T14:30:00Z', '2026-07-05T14:30:00Z'),
  ('2734fc3a-05aa-4c0e-b780-65474fc5f1a6', 'S1-4', null, null, '2026-07-05T14:30:00Z', '2026-07-05T14:30:00Z'),
  ('2734fc3a-05aa-4c0e-b780-65474fc5f1a6', 'S2-1', '94506', 'Internal estimate', '2026-07-05T14:30:00Z', '2026-07-05T14:30:00Z'),
  ('2734fc3a-05aa-4c0e-b780-65474fc5f1a6', 'S2-2', '106929', null, '2026-07-05T14:30:00Z', '2026-07-05T14:30:00Z'),
  ('2734fc3a-05aa-4c0e-b780-65474fc5f1a6', 'S2-3', null, null, '2026-07-05T14:30:00Z', '2026-07-05T14:30:00Z'),
  ('2734fc3a-05aa-4c0e-b780-65474fc5f1a6', 'S2-4', 'No', null, '2026-07-05T14:30:00Z', '2026-07-05T14:30:00Z'),
  ('2734fc3a-05aa-4c0e-b780-65474fc5f1a6', 'S2-5', 'Energy efficiency audit planned for 2027. No quantified projects yet.', null, '2026-07-05T14:30:00Z', '2026-07-05T14:30:00Z'),
  ('2734fc3a-05aa-4c0e-b780-65474fc5f1a6', 'S2-6', 'No dedicated sustainability budget or headcount. Awaiting customer requirements before committing capex.', null, '2026-07-05T14:30:00Z', '2026-07-05T14:30:00Z'),
  ('2734fc3a-05aa-4c0e-b780-65474fc5f1a6', 'S3-1', '12400', null, '2026-07-05T14:30:00Z', '2026-07-05T14:30:00Z'),
  ('2734fc3a-05aa-4c0e-b780-65474fc5f1a6', 'S3-2', 'Yes', null, '2026-07-05T14:30:00Z', '2026-07-05T14:30:00Z'),
  ('2734fc3a-05aa-4c0e-b780-65474fc5f1a6', 'S3-3', null, null, '2026-07-05T14:30:00Z', '2026-07-05T14:30:00Z'),
  ('2734fc3a-05aa-4c0e-b780-65474fc5f1a6', 'S3-4', 'Discharge to municipal system under local permit. No additional on-site treatment.', null, '2026-07-05T14:30:00Z', '2026-07-05T14:30:00Z'),
  ('2734fc3a-05aa-4c0e-b780-65474fc5f1a6', 'S4-1', '569101', 'Municipal + groundwater', '2026-07-05T14:30:00Z', '2026-07-05T14:30:00Z'),
  ('2734fc3a-05aa-4c0e-b780-65474fc5f1a6', 'S4-2', 'Yes', null, '2026-07-05T14:30:00Z', '2026-07-05T14:30:00Z'),
  ('2734fc3a-05aa-4c0e-b780-65474fc5f1a6', 'S4-3', 'None implemented. Intensity not tracked at unit level.', null, '2026-07-05T14:30:00Z', '2026-07-05T14:30:00Z'),
  ('2734fc3a-05aa-4c0e-b780-65474fc5f1a6', 'S4-4', 'Under development, due 2027.', null, '2026-07-05T14:30:00Z', '2026-07-05T14:30:00Z'),
  ('2734fc3a-05aa-4c0e-b780-65474fc5f1a6', 'S5-1', '4280', 'Breakdown: landfill 809, recycled 2735, energy recovery 428, hazardous 243.', '2026-07-05T14:30:00Z', '2026-07-05T14:30:00Z'),
  ('2734fc3a-05aa-4c0e-b780-65474fc5f1a6', 'S5-2', '4', null, '2026-07-05T14:30:00Z', '2026-07-05T14:30:00Z'),
  ('2734fc3a-05aa-4c0e-b780-65474fc5f1a6', 'S5-3', 'No specific circularity measures for supplied components at this time.', null, '2026-07-05T14:30:00Z', '2026-07-05T14:30:00Z'),
  ('2734fc3a-05aa-4c0e-b780-65474fc5f1a6', 'S5-4', 'Waste segregated per legal requirements; majority of residual waste to landfill. No ZWTL target.', null, '2026-07-05T14:30:00Z', '2026-07-05T14:30:00Z'),
  ('2734fc3a-05aa-4c0e-b780-65474fc5f1a6', 'S6-1', 'No', null, '2026-07-05T14:30:00Z', '2026-07-05T14:30:00Z'),
  ('2734fc3a-05aa-4c0e-b780-65474fc5f1a6', 'S6-2', 'None.', null, '2026-07-05T14:30:00Z', '2026-07-05T14:30:00Z'),
  ('2734fc3a-05aa-4c0e-b780-65474fc5f1a6', 'S6-3', 'No. No assessment planned.', null, '2026-07-05T14:30:00Z', '2026-07-05T14:30:00Z'),
  ('2734fc3a-05aa-4c0e-b780-65474fc5f1a6', 'S7-1', 'No', null, '2026-07-05T14:30:00Z', '2026-07-05T14:30:00Z'),
  ('2734fc3a-05aa-4c0e-b780-65474fc5f1a6', 'S7-2', 'No', null, '2026-07-05T14:30:00Z', '2026-07-05T14:30:00Z'),
  ('2734fc3a-05aa-4c0e-b780-65474fc5f1a6', 'S7-3', 'Workers may raise issues with supervisors. No formal count kept.', null, '2026-07-05T14:30:00Z', '2026-07-05T14:30:00Z'),
  ('2734fc3a-05aa-4c0e-b780-65474fc5f1a6', 'S7-4', 'No', null, '2026-07-05T14:30:00Z', '2026-07-05T14:30:00Z'),
  ('2734fc3a-05aa-4c0e-b780-65474fc5f1a6', 'S7-5', 'Code of conduct available on request; compliance monitored informally. No third-party audits in the last 24 months.', null, '2026-07-05T14:30:00Z', '2026-07-05T14:30:00Z'),
  ('3c11c753-7ce7-4f36-aba2-914faa9d0a9d', 'S1-1', 'Tech Precision Co. Ltd., China', null, '2026-06-20T14:30:00Z', '2026-06-20T14:30:00Z'),
  ('3c11c753-7ce7-4f36-aba2-914faa9d0a9d', 'S1-2', 'Jing Li, ESG Coordinator, jing.li.techprecision@example.com', null, '2026-06-20T14:30:00Z', '2026-06-20T14:30:00Z'),
  ('3c11c753-7ce7-4f36-aba2-914faa9d0a9d', 'S1-3', 'No — Will Complete Questionnaire', null, '2026-06-20T14:30:00Z', '2026-06-20T14:30:00Z'),
  ('3c11c753-7ce7-4f36-aba2-914faa9d0a9d', 'S1-4', null, null, '2026-06-20T14:30:00Z', '2026-06-20T14:30:00Z'),
  ('3c11c753-7ce7-4f36-aba2-914faa9d0a9d', 'S2-1', '68396', 'ISO 14064-3 limited assurance', '2026-06-20T14:30:00Z', '2026-06-20T14:30:00Z'),
  ('3c11c753-7ce7-4f36-aba2-914faa9d0a9d', 'S2-2', '42404', null, '2026-06-20T14:30:00Z', '2026-06-20T14:30:00Z'),
  ('3c11c753-7ce7-4f36-aba2-914faa9d0a9d', 'S2-3', '516699', 'Cat 1,3,4,5,6,7', '2026-06-20T14:30:00Z', '2026-06-20T14:30:00Z'),
  ('3c11c753-7ce7-4f36-aba2-914faa9d0a9d', 'S2-4', 'No', null, '2026-06-20T14:30:00Z', '2026-06-20T14:30:00Z'),
  ('3c11c753-7ce7-4f36-aba2-914faa9d0a9d', 'S2-5', '1) On-site solar feasibility study underway (69% renewable share today). 2) Compressed air leak programme, est. 400 tCO2e/yr. 3) LED retrofit completed 2025.', null, '2026-06-20T14:30:00Z', '2026-06-20T14:30:00Z'),
  ('3c11c753-7ce7-4f36-aba2-914faa9d0a9d', 'S2-6', 'Capex competition with capacity expansion; limited access to green financing; renewable tariffs not yet available at our grid location.', null, '2026-06-20T14:30:00Z', '2026-06-20T14:30:00Z'),
  ('3c11c753-7ce7-4f36-aba2-914faa9d0a9d', 'S3-1', '722', null, '2026-06-20T14:30:00Z', '2026-06-20T14:30:00Z'),
  ('3c11c753-7ce7-4f36-aba2-914faa9d0a9d', 'S3-2', 'No', null, '2026-06-20T14:30:00Z', '2026-06-20T14:30:00Z'),
  ('3c11c753-7ce7-4f36-aba2-914faa9d0a9d', 'S3-3', null, null, '2026-06-20T14:30:00Z', '2026-06-20T14:30:00Z'),
  ('3c11c753-7ce7-4f36-aba2-914faa9d0a9d', 'S3-4', 'Primary treatment on site, discharge to municipal treatment under permit. Quarterly third-party sampling for heavy metals and COD.', null, '2026-06-20T14:30:00Z', '2026-06-20T14:30:00Z'),
  ('3c11c753-7ce7-4f36-aba2-914faa9d0a9d', 'S4-1', '617345', 'Municipal + groundwater', '2026-06-20T14:30:00Z', '2026-06-20T14:30:00Z'),
  ('3c11c753-7ce7-4f36-aba2-914faa9d0a9d', 'S4-2', 'Yes', null, '2026-06-20T14:30:00Z', '2026-06-20T14:30:00Z'),
  ('3c11c753-7ce7-4f36-aba2-914faa9d0a9d', 'S4-3', 'Cooling tower blowdown recovery installed 2025. Intensity roughly flat over three years; metering upgraded in 2024.', null, '2026-06-20T14:30:00Z', '2026-06-20T14:30:00Z'),
  ('3c11c753-7ce7-4f36-aba2-914faa9d0a9d', 'S4-4', 'Under development, due 2027.', null, '2026-06-20T14:30:00Z', '2026-06-20T14:30:00Z'),
  ('3c11c753-7ce7-4f36-aba2-914faa9d0a9d', 'S5-1', '5307', 'Breakdown: landfill 1515, recycled 3015, energy recovery 531, hazardous 487.', '2026-06-20T14:30:00Z', '2026-06-20T14:30:00Z'),
  ('3c11c753-7ce7-4f36-aba2-914faa9d0a9d', 'S5-2', '23', null, '2026-06-20T14:30:00Z', '2026-06-20T14:30:00Z'),
  ('3c11c753-7ce7-4f36-aba2-914faa9d0a9d', 'S5-3', 'Increasing PCR share in housings; regrind of internal scrap into non-cosmetic parts.', null, '2026-06-20T14:30:00Z', '2026-06-20T14:30:00Z'),
  ('3c11c753-7ce7-4f36-aba2-914faa9d0a9d', 'S5-4', 'Diversion around 70%. Main streams: mixed plastics and packaging to recycling; hazardous sludge to licensed treatment. Evaluating waste-to-energy for residuals.', null, '2026-06-20T14:30:00Z', '2026-06-20T14:30:00Z'),
  ('3c11c753-7ce7-4f36-aba2-914faa9d0a9d', 'S6-1', 'No', null, '2026-06-20T14:30:00Z', '2026-06-20T14:30:00Z'),
  ('3c11c753-7ce7-4f36-aba2-914faa9d0a9d', 'S6-2', 'Landscaping with native species; light curfew on non-production areas.', null, '2026-06-20T14:30:00Z', '2026-06-20T14:30:00Z'),
  ('3c11c753-7ce7-4f36-aba2-914faa9d0a9d', 'S6-3', 'No. Target date: Q4 2027.', null, '2026-06-20T14:30:00Z', '2026-06-20T14:30:00Z'),
  ('3c11c753-7ce7-4f36-aba2-914faa9d0a9d', 'S7-1', 'No', null, '2026-06-20T14:30:00Z', '2026-06-20T14:30:00Z'),
  ('3c11c753-7ce7-4f36-aba2-914faa9d0a9d', 'S7-2', 'Yes', null, '2026-06-20T14:30:00Z', '2026-06-20T14:30:00Z'),
  ('3c11c753-7ce7-4f36-aba2-914faa9d0a9d', 'S7-3', 'Suggestion boxes and HR open-door process. 3 grievances filed, 3 resolved in the last 12 months.', null, '2026-06-20T14:30:00Z', '2026-06-20T14:30:00Z'),
  ('3c11c753-7ce7-4f36-aba2-914faa9d0a9d', 'S7-4', 'No', null, '2026-06-20T14:30:00Z', '2026-06-20T14:30:00Z'),
  ('3c11c753-7ce7-4f36-aba2-914faa9d0a9d', 'S7-5', 'Code of conduct signed by key suppliers at onboarding; 2 third-party audits in the last 24 months.', null, '2026-06-20T14:30:00Z', '2026-06-20T14:30:00Z'),
  ('72a4d1eb-00f2-47a0-9264-e4d88b99c2c7', 'S1-1', 'Electro Components Co. Ltd., Taiwan', null, '2026-07-04T14:30:00Z', '2026-07-04T14:30:00Z'),
  ('72a4d1eb-00f2-47a0-9264-e4d88b99c2c7', 'S1-2', 'Wei Huang, ESG Coordinator, wei.huang.electrocomponents@example.com', null, '2026-07-04T14:30:00Z', '2026-07-04T14:30:00Z'),
  ('72a4d1eb-00f2-47a0-9264-e4d88b99c2c7', 'S1-3', 'No — Will Complete Questionnaire', null, '2026-07-04T14:30:00Z', '2026-07-04T14:30:00Z'),
  ('72a4d1eb-00f2-47a0-9264-e4d88b99c2c7', 'S1-4', null, null, '2026-07-04T14:30:00Z', '2026-07-04T14:30:00Z'),
  ('72a4d1eb-00f2-47a0-9264-e4d88b99c2c7', 'S2-1', '29093', 'Third-party verified', '2026-07-04T14:30:00Z', '2026-07-04T14:30:00Z'),
  ('72a4d1eb-00f2-47a0-9264-e4d88b99c2c7', 'S2-2', '44988', null, '2026-07-04T14:30:00Z', '2026-07-04T14:30:00Z'),
  ('72a4d1eb-00f2-47a0-9264-e4d88b99c2c7', 'S2-3', null, null, '2026-07-04T14:30:00Z', '2026-07-04T14:30:00Z'),
  ('72a4d1eb-00f2-47a0-9264-e4d88b99c2c7', 'S2-4', 'Yes', null, '2026-07-04T14:30:00Z', '2026-07-04T14:30:00Z'),
  ('72a4d1eb-00f2-47a0-9264-e4d88b99c2c7', 'S2-5', '1) On-site solar feasibility study underway (25% renewable share today). 2) Compressed air leak programme, est. 400 tCO2e/yr. 3) LED retrofit completed 2025.', null, '2026-07-04T14:30:00Z', '2026-07-04T14:30:00Z'),
  ('72a4d1eb-00f2-47a0-9264-e4d88b99c2c7', 'S2-6', 'Capex competition with capacity expansion; limited access to green financing; renewable tariffs not yet available at our grid location.', null, '2026-07-04T14:30:00Z', '2026-07-04T14:30:00Z'),
  ('72a4d1eb-00f2-47a0-9264-e4d88b99c2c7', 'S3-1', '31771', null, '2026-07-04T14:30:00Z', '2026-07-04T14:30:00Z'),
  ('72a4d1eb-00f2-47a0-9264-e4d88b99c2c7', 'S3-2', 'Yes', null, '2026-07-04T14:30:00Z', '2026-07-04T14:30:00Z'),
  ('72a4d1eb-00f2-47a0-9264-e4d88b99c2c7', 'S3-3', 'Alternatives under evaluation with coating supplier; no validated substitute yet. Target phase-out: 2029.', null, '2026-07-04T14:30:00Z', '2026-07-04T14:30:00Z'),
  ('72a4d1eb-00f2-47a0-9264-e4d88b99c2c7', 'S3-4', 'Primary treatment on site, discharge to municipal treatment under permit. Quarterly third-party sampling for heavy metals and COD.', null, '2026-07-04T14:30:00Z', '2026-07-04T14:30:00Z'),
  ('72a4d1eb-00f2-47a0-9264-e4d88b99c2c7', 'S4-1', '524553', 'Groundwater', '2026-07-04T14:30:00Z', '2026-07-04T14:30:00Z'),
  ('72a4d1eb-00f2-47a0-9264-e4d88b99c2c7', 'S4-2', 'No', null, '2026-07-04T14:30:00Z', '2026-07-04T14:30:00Z'),
  ('72a4d1eb-00f2-47a0-9264-e4d88b99c2c7', 'S4-3', 'Cooling tower blowdown recovery installed 2025. Intensity roughly flat over three years; metering upgraded in 2024.', null, '2026-07-04T14:30:00Z', '2026-07-04T14:30:00Z'),
  ('72a4d1eb-00f2-47a0-9264-e4d88b99c2c7', 'S4-4', null, null, '2026-07-04T14:30:00Z', '2026-07-04T14:30:00Z'),
  ('72a4d1eb-00f2-47a0-9264-e4d88b99c2c7', 'S5-1', '5069', 'Breakdown: landfill 2089, recycled 2336, energy recovery 507, hazardous 204.', '2026-07-04T14:30:00Z', '2026-07-04T14:30:00Z'),
  ('72a4d1eb-00f2-47a0-9264-e4d88b99c2c7', 'S5-2', '20', null, '2026-07-04T14:30:00Z', '2026-07-04T14:30:00Z'),
  ('72a4d1eb-00f2-47a0-9264-e4d88b99c2c7', 'S5-3', 'Increasing PCR share in housings; regrind of internal scrap into non-cosmetic parts.', null, '2026-07-04T14:30:00Z', '2026-07-04T14:30:00Z'),
  ('72a4d1eb-00f2-47a0-9264-e4d88b99c2c7', 'S5-4', 'Diversion around 70%. Main streams: mixed plastics and packaging to recycling; hazardous sludge to licensed treatment. Evaluating waste-to-energy for residuals.', null, '2026-07-04T14:30:00Z', '2026-07-04T14:30:00Z'),
  ('72a4d1eb-00f2-47a0-9264-e4d88b99c2c7', 'S6-1', 'No', null, '2026-07-04T14:30:00Z', '2026-07-04T14:30:00Z'),
  ('72a4d1eb-00f2-47a0-9264-e4d88b99c2c7', 'S6-2', 'Landscaping with native species; light curfew on non-production areas.', null, '2026-07-04T14:30:00Z', '2026-07-04T14:30:00Z'),
  ('72a4d1eb-00f2-47a0-9264-e4d88b99c2c7', 'S6-3', 'No. Target date: Q4 2027.', null, '2026-07-04T14:30:00Z', '2026-07-04T14:30:00Z'),
  ('72a4d1eb-00f2-47a0-9264-e4d88b99c2c7', 'S7-1', 'No', null, '2026-07-04T14:30:00Z', '2026-07-04T14:30:00Z'),
  ('72a4d1eb-00f2-47a0-9264-e4d88b99c2c7', 'S7-2', 'No', null, '2026-07-04T14:30:00Z', '2026-07-04T14:30:00Z'),
  ('72a4d1eb-00f2-47a0-9264-e4d88b99c2c7', 'S7-3', 'Suggestion boxes and HR open-door process. 3 grievances filed, 3 resolved in the last 12 months.', null, '2026-07-04T14:30:00Z', '2026-07-04T14:30:00Z'),
  ('72a4d1eb-00f2-47a0-9264-e4d88b99c2c7', 'S7-4', 'No', null, '2026-07-04T14:30:00Z', '2026-07-04T14:30:00Z'),
  ('72a4d1eb-00f2-47a0-9264-e4d88b99c2c7', 'S7-5', 'Code of conduct signed by key suppliers at onboarding; 2 third-party audits in the last 24 months.', null, '2026-07-04T14:30:00Z', '2026-07-04T14:30:00Z'),
  ('1041d63b-6a97-49c9-95d6-d75e86eacbc0', 'S1-1', 'Nexus Chemicals GmbH, Germany', null, '2026-06-16T14:30:00Z', '2026-06-16T14:30:00Z'),
  ('1041d63b-6a97-49c9-95d6-d75e86eacbc0', 'S1-2', 'Michael Muller, ESG Coordinator, michael.muller.nexuschemicals@example.com', null, '2026-06-16T14:30:00Z', '2026-06-16T14:30:00Z'),
  ('1041d63b-6a97-49c9-95d6-d75e86eacbc0', 'S1-3', 'No — Will Complete Questionnaire', null, '2026-06-16T14:30:00Z', '2026-06-16T14:30:00Z'),
  ('1041d63b-6a97-49c9-95d6-d75e86eacbc0', 'S1-4', null, null, '2026-06-16T14:30:00Z', '2026-06-16T14:30:00Z'),
  ('1041d63b-6a97-49c9-95d6-d75e86eacbc0', 'S2-1', '15870', 'Internal estimate', '2026-06-16T14:30:00Z', '2026-06-16T14:30:00Z'),
  ('1041d63b-6a97-49c9-95d6-d75e86eacbc0', 'S2-2', '29114', null, '2026-06-16T14:30:00Z', '2026-06-16T14:30:00Z'),
  ('1041d63b-6a97-49c9-95d6-d75e86eacbc0', 'S2-3', null, null, '2026-06-16T14:30:00Z', '2026-06-16T14:30:00Z'),
  ('1041d63b-6a97-49c9-95d6-d75e86eacbc0', 'S2-4', 'No', null, '2026-06-16T14:30:00Z', '2026-06-16T14:30:00Z'),
  ('1041d63b-6a97-49c9-95d6-d75e86eacbc0', 'S2-5', 'Energy efficiency audit planned for 2027. No quantified projects yet.', null, '2026-06-16T14:30:00Z', '2026-06-16T14:30:00Z'),
  ('1041d63b-6a97-49c9-95d6-d75e86eacbc0', 'S2-6', 'No dedicated sustainability budget or headcount. Awaiting customer requirements before committing capex.', null, '2026-06-16T14:30:00Z', '2026-06-16T14:30:00Z'),
  ('1041d63b-6a97-49c9-95d6-d75e86eacbc0', 'S3-1', '0', null, '2026-06-16T14:30:00Z', '2026-06-16T14:30:00Z'),
  ('1041d63b-6a97-49c9-95d6-d75e86eacbc0', 'S3-2', 'No', null, '2026-06-16T14:30:00Z', '2026-06-16T14:30:00Z'),
  ('1041d63b-6a97-49c9-95d6-d75e86eacbc0', 'S3-3', null, null, '2026-06-16T14:30:00Z', '2026-06-16T14:30:00Z'),
  ('1041d63b-6a97-49c9-95d6-d75e86eacbc0', 'S3-4', 'Discharge to municipal system under local permit. No additional on-site treatment.', null, '2026-06-16T14:30:00Z', '2026-06-16T14:30:00Z'),
  ('1041d63b-6a97-49c9-95d6-d75e86eacbc0', 'S4-1', '650208', 'Municipal + groundwater', '2026-06-16T14:30:00Z', '2026-06-16T14:30:00Z'),
  ('1041d63b-6a97-49c9-95d6-d75e86eacbc0', 'S4-2', 'No', null, '2026-06-16T14:30:00Z', '2026-06-16T14:30:00Z'),
  ('1041d63b-6a97-49c9-95d6-d75e86eacbc0', 'S4-3', 'None implemented. Intensity not tracked at unit level.', null, '2026-06-16T14:30:00Z', '2026-06-16T14:30:00Z'),
  ('1041d63b-6a97-49c9-95d6-d75e86eacbc0', 'S4-4', null, null, '2026-06-16T14:30:00Z', '2026-06-16T14:30:00Z'),
  ('1041d63b-6a97-49c9-95d6-d75e86eacbc0', 'S5-1', '4748', 'Breakdown: landfill 1656, recycled 1488, energy recovery 475, hazardous 233.', '2026-06-16T14:30:00Z', '2026-06-16T14:30:00Z'),
  ('1041d63b-6a97-49c9-95d6-d75e86eacbc0', 'S5-2', '7', null, '2026-06-16T14:30:00Z', '2026-06-16T14:30:00Z'),
  ('1041d63b-6a97-49c9-95d6-d75e86eacbc0', 'S5-3', 'No specific circularity measures for supplied components at this time.', null, '2026-06-16T14:30:00Z', '2026-06-16T14:30:00Z'),
  ('1041d63b-6a97-49c9-95d6-d75e86eacbc0', 'S5-4', 'Waste segregated per legal requirements; majority of residual waste to landfill. No ZWTL target.', null, '2026-06-16T14:30:00Z', '2026-06-16T14:30:00Z'),
  ('1041d63b-6a97-49c9-95d6-d75e86eacbc0', 'S6-1', 'No', null, '2026-06-16T14:30:00Z', '2026-06-16T14:30:00Z'),
  ('1041d63b-6a97-49c9-95d6-d75e86eacbc0', 'S6-2', 'None.', null, '2026-06-16T14:30:00Z', '2026-06-16T14:30:00Z'),
  ('1041d63b-6a97-49c9-95d6-d75e86eacbc0', 'S6-3', 'No. No assessment planned.', null, '2026-06-16T14:30:00Z', '2026-06-16T14:30:00Z'),
  ('1041d63b-6a97-49c9-95d6-d75e86eacbc0', 'S7-1', 'No', null, '2026-06-16T14:30:00Z', '2026-06-16T14:30:00Z'),
  ('1041d63b-6a97-49c9-95d6-d75e86eacbc0', 'S7-2', 'No', null, '2026-06-16T14:30:00Z', '2026-06-16T14:30:00Z'),
  ('1041d63b-6a97-49c9-95d6-d75e86eacbc0', 'S7-3', 'Workers may raise issues with supervisors. No formal count kept.', null, '2026-06-16T14:30:00Z', '2026-06-16T14:30:00Z'),
  ('1041d63b-6a97-49c9-95d6-d75e86eacbc0', 'S7-4', 'No', null, '2026-06-16T14:30:00Z', '2026-06-16T14:30:00Z'),
  ('1041d63b-6a97-49c9-95d6-d75e86eacbc0', 'S7-5', 'Code of conduct available on request; compliance monitored informally. No third-party audits in the last 24 months.', null, '2026-06-16T14:30:00Z', '2026-06-16T14:30:00Z'),
  ('1712138a-c8a6-47e6-97db-7617baf11f84', 'S1-1', 'Alpha Materials S.A. de C.V., Mexico', null, '2026-06-17T14:30:00Z', '2026-06-17T14:30:00Z'),
  ('1712138a-c8a6-47e6-97db-7617baf11f84', 'S1-2', 'Alejandro Garcia, ESG Coordinator, alejandro.garcia.alphamaterials@example.com', null, '2026-06-17T14:30:00Z', '2026-06-17T14:30:00Z'),
  ('1712138a-c8a6-47e6-97db-7617baf11f84', 'S1-3', 'No — Will Complete Questionnaire', null, '2026-06-17T14:30:00Z', '2026-06-17T14:30:00Z'),
  ('1712138a-c8a6-47e6-97db-7617baf11f84', 'S1-4', null, null, '2026-06-17T14:30:00Z', '2026-06-17T14:30:00Z'),
  ('1712138a-c8a6-47e6-97db-7617baf11f84', 'S2-1', '34706', 'Internal estimate', '2026-06-17T14:30:00Z', '2026-06-17T14:30:00Z'),
  ('1712138a-c8a6-47e6-97db-7617baf11f84', 'S2-2', '20820', null, '2026-06-17T14:30:00Z', '2026-06-17T14:30:00Z'),
  ('1712138a-c8a6-47e6-97db-7617baf11f84', 'S2-3', '140703', 'Cat 1,4 only', '2026-06-17T14:30:00Z', '2026-06-17T14:30:00Z'),
  ('1712138a-c8a6-47e6-97db-7617baf11f84', 'S2-4', 'No', null, '2026-06-17T14:30:00Z', '2026-06-17T14:30:00Z'),
  ('1712138a-c8a6-47e6-97db-7617baf11f84', 'S2-5', 'Energy efficiency audit planned for 2027. No quantified projects yet.', null, '2026-06-17T14:30:00Z', '2026-06-17T14:30:00Z'),
  ('1712138a-c8a6-47e6-97db-7617baf11f84', 'S2-6', 'No dedicated sustainability budget or headcount. Awaiting customer requirements before committing capex.', null, '2026-06-17T14:30:00Z', '2026-06-17T14:30:00Z'),
  ('1712138a-c8a6-47e6-97db-7617baf11f84', 'S3-1', '0', null, '2026-06-17T14:30:00Z', '2026-06-17T14:30:00Z'),
  ('1712138a-c8a6-47e6-97db-7617baf11f84', 'S3-2', 'No', null, '2026-06-17T14:30:00Z', '2026-06-17T14:30:00Z'),
  ('1712138a-c8a6-47e6-97db-7617baf11f84', 'S3-3', null, null, '2026-06-17T14:30:00Z', '2026-06-17T14:30:00Z'),
  ('1712138a-c8a6-47e6-97db-7617baf11f84', 'S3-4', 'Discharge to municipal system under local permit. No additional on-site treatment.', null, '2026-06-17T14:30:00Z', '2026-06-17T14:30:00Z'),
  ('1712138a-c8a6-47e6-97db-7617baf11f84', 'S4-1', '171778', 'Groundwater', '2026-06-17T14:30:00Z', '2026-06-17T14:30:00Z'),
  ('1712138a-c8a6-47e6-97db-7617baf11f84', 'S4-2', 'Yes', null, '2026-06-17T14:30:00Z', '2026-06-17T14:30:00Z'),
  ('1712138a-c8a6-47e6-97db-7617baf11f84', 'S4-3', 'None implemented. Intensity not tracked at unit level.', null, '2026-06-17T14:30:00Z', '2026-06-17T14:30:00Z'),
  ('1712138a-c8a6-47e6-97db-7617baf11f84', 'S4-4', 'Under development, due 2027.', null, '2026-06-17T14:30:00Z', '2026-06-17T14:30:00Z'),
  ('1712138a-c8a6-47e6-97db-7617baf11f84', 'S5-1', null, null, '2026-06-17T14:30:00Z', '2026-06-17T14:30:00Z'),
  ('1712138a-c8a6-47e6-97db-7617baf11f84', 'S5-2', '4', null, '2026-06-17T14:30:00Z', '2026-06-17T14:30:00Z'),
  ('1712138a-c8a6-47e6-97db-7617baf11f84', 'S5-3', 'No specific circularity measures for supplied components at this time.', null, '2026-06-17T14:30:00Z', '2026-06-17T14:30:00Z'),
  ('1712138a-c8a6-47e6-97db-7617baf11f84', 'S5-4', 'Waste segregated per legal requirements; majority of residual waste to landfill. No ZWTL target.', null, '2026-06-17T14:30:00Z', '2026-06-17T14:30:00Z'),
  ('1712138a-c8a6-47e6-97db-7617baf11f84', 'S6-1', 'No', null, '2026-06-17T14:30:00Z', '2026-06-17T14:30:00Z'),
  ('1712138a-c8a6-47e6-97db-7617baf11f84', 'S6-2', 'None.', null, '2026-06-17T14:30:00Z', '2026-06-17T14:30:00Z'),
  ('1712138a-c8a6-47e6-97db-7617baf11f84', 'S6-3', 'No. No assessment planned.', null, '2026-06-17T14:30:00Z', '2026-06-17T14:30:00Z'),
  ('1712138a-c8a6-47e6-97db-7617baf11f84', 'S7-1', 'No', null, '2026-06-17T14:30:00Z', '2026-06-17T14:30:00Z'),
  ('1712138a-c8a6-47e6-97db-7617baf11f84', 'S7-2', 'No', null, '2026-06-17T14:30:00Z', '2026-06-17T14:30:00Z'),
  ('1712138a-c8a6-47e6-97db-7617baf11f84', 'S7-3', 'Workers may raise issues with supervisors. No formal count kept.', null, '2026-06-17T14:30:00Z', '2026-06-17T14:30:00Z'),
  ('1712138a-c8a6-47e6-97db-7617baf11f84', 'S7-4', 'No', null, '2026-06-17T14:30:00Z', '2026-06-17T14:30:00Z'),
  ('1712138a-c8a6-47e6-97db-7617baf11f84', 'S7-5', 'Code of conduct available on request; compliance monitored informally. No third-party audits in the last 24 months.', null, '2026-06-17T14:30:00Z', '2026-06-17T14:30:00Z'),
  ('e8e3f826-183b-4473-b3cc-f8d901f41208', 'S1-1', 'Nova Components s.r.o., Czechia', null, '2026-07-06T14:30:00Z', '2026-07-06T14:30:00Z'),
  ('e8e3f826-183b-4473-b3cc-f8d901f41208', 'S1-2', 'Petra Novak, ESG Coordinator, petra.novak.novacomponents@example.com', null, '2026-07-06T14:30:00Z', '2026-07-06T14:30:00Z'),
  ('e8e3f826-183b-4473-b3cc-f8d901f41208', 'S1-3', 'No — Will Complete Questionnaire', null, '2026-07-06T14:30:00Z', '2026-07-06T14:30:00Z'),
  ('e8e3f826-183b-4473-b3cc-f8d901f41208', 'S1-4', null, null, '2026-07-06T14:30:00Z', '2026-07-06T14:30:00Z'),
  ('e8e3f826-183b-4473-b3cc-f8d901f41208', 'S2-1', '16190', 'Third-party verified', '2026-07-06T14:30:00Z', '2026-07-06T14:30:00Z'),
  ('e8e3f826-183b-4473-b3cc-f8d901f41208', 'S2-2', '17204', null, '2026-07-06T14:30:00Z', '2026-07-06T14:30:00Z'),
  ('e8e3f826-183b-4473-b3cc-f8d901f41208', 'S2-3', '50102', 'Cat 1,4 only', '2026-07-06T14:30:00Z', '2026-07-06T14:30:00Z'),
  ('e8e3f826-183b-4473-b3cc-f8d901f41208', 'S2-4', 'Yes', null, '2026-07-06T14:30:00Z', '2026-07-06T14:30:00Z'),
  ('e8e3f826-183b-4473-b3cc-f8d901f41208', 'S2-5', '1) Rooftop solar PPA expansion (85% renewable electricity today), est. 4,500 tCO2e/yr. 2) Electrification of process heat on line 2, est. 2,100 tCO2e/yr. 3) Fleet conversion to EV for intra-site logistics, est. 600 tCO2e/yr.', null, '2026-07-06T14:30:00Z', '2026-07-06T14:30:00Z'),
  ('e8e3f826-183b-4473-b3cc-f8d901f41208', 'S2-6', 'Grid capacity constraints for additional PPA volume; long payback on heat electrification at current gas prices.', null, '2026-07-06T14:30:00Z', '2026-07-06T14:30:00Z'),
  ('e8e3f826-183b-4473-b3cc-f8d901f41208', 'S3-1', '42002', null, '2026-07-06T14:30:00Z', '2026-07-06T14:30:00Z'),
  ('e8e3f826-183b-4473-b3cc-f8d901f41208', 'S3-2', 'Yes', null, '2026-07-06T14:30:00Z', '2026-07-06T14:30:00Z'),
  ('e8e3f826-183b-4473-b3cc-f8d901f41208', 'S3-3', 'Yes — non-PFAS alternative validated for 2 of 3 applications; qualification with The Corporate underway. Full phase-out target: end 2027.', null, '2026-07-06T14:30:00Z', '2026-07-06T14:30:00Z'),
  ('e8e3f826-183b-4473-b3cc-f8d901f41208', 'S3-4', 'Dedicated on-site effluent treatment (DAF + biological + activated carbon), continuous pH/COD monitoring with automatic diversion to holding tanks on exceedance. Zero liquid discharge target 2028.', null, '2026-07-06T14:30:00Z', '2026-07-06T14:30:00Z'),
  ('e8e3f826-183b-4473-b3cc-f8d901f41208', 'S4-1', '538373', 'Groundwater', '2026-07-06T14:30:00Z', '2026-07-06T14:30:00Z'),
  ('e8e3f826-183b-4473-b3cc-f8d901f41208', 'S4-2', 'Yes', null, '2026-07-06T14:30:00Z', '2026-07-06T14:30:00Z'),
  ('e8e3f826-183b-4473-b3cc-f8d901f41208', 'S4-3', 'Closed-loop cooling retrofit completed 2024; rinse-water countercurrent reuse in plating. Water intensity down 22% over three years.', null, '2026-07-06T14:30:00Z', '2026-07-06T14:30:00Z'),
  ('e8e3f826-183b-4473-b3cc-f8d901f41208', 'S4-4', 'Dual-source agreement with municipal utility; 3-day buffer storage; production reallocation protocol to sister site.', null, '2026-07-06T14:30:00Z', '2026-07-06T14:30:00Z'),
  ('e8e3f826-183b-4473-b3cc-f8d901f41208', 'S5-1', '345', 'Breakdown: landfill 124, recycled 233, energy recovery 34, hazardous 26.', '2026-07-06T14:30:00Z', '2026-07-06T14:30:00Z'),
  ('e8e3f826-183b-4473-b3cc-f8d901f41208', 'S5-2', '45', null, '2026-07-06T14:30:00Z', '2026-07-06T14:30:00Z'),
  ('e8e3f826-183b-4473-b3cc-f8d901f41208', 'S5-3', 'Components redesigned for disassembly (snap-fit replacing adhesive); PCR content roadmap agreed with The Corporate engineering; takeback pilot for production offcuts.', null, '2026-07-06T14:30:00Z', '2026-07-06T14:30:00Z'),
  ('e8e3f826-183b-4473-b3cc-f8d901f41208', 'S5-4', '94% diversion today. Main streams: metal offcuts (recycled), plastic runners (regrind), packaging (reuse loop with suppliers). ZWTL certification targeted 2027.', null, '2026-07-06T14:30:00Z', '2026-07-06T14:30:00Z'),
  ('e8e3f826-183b-4473-b3cc-f8d901f41208', 'S6-1', 'No', null, '2026-07-06T14:30:00Z', '2026-07-06T14:30:00Z'),
  ('e8e3f826-183b-4473-b3cc-f8d901f41208', 'S6-2', 'Native planting buffer along site perimeter, warm-white shielded lighting, stormwater retention wetland. Annual ecology walkover with local university.', null, '2026-07-06T14:30:00Z', '2026-07-06T14:30:00Z'),
  ('e8e3f826-183b-4473-b3cc-f8d901f41208', 'S6-3', 'Yes — TNFD-aligned screening completed 2025. Key finding: moderate water-related dependency at primary site; no critical habitat impact. Full assessment planned 2027.', null, '2026-07-06T14:30:00Z', '2026-07-06T14:30:00Z'),
  ('e8e3f826-183b-4473-b3cc-f8d901f41208', 'S7-1', 'Yes', null, '2026-07-06T14:30:00Z', '2026-07-06T14:30:00Z'),
  ('e8e3f826-183b-4473-b3cc-f8d901f41208', 'S7-2', 'Yes', null, '2026-07-06T14:30:00Z', '2026-07-06T14:30:00Z'),
  ('e8e3f826-183b-4473-b3cc-f8d901f41208', 'S7-3', 'Anonymous multilingual hotline plus worker committee, operated by third party. 14 grievances filed, 14 resolved (median 9 days) in the last 12 months.', null, '2026-07-06T14:30:00Z', '2026-07-06T14:30:00Z'),
  ('e8e3f826-183b-4473-b3cc-f8d901f41208', 'S7-4', 'Yes', null, '2026-07-06T14:30:00Z', '2026-07-06T14:30:00Z'),
  ('e8e3f826-183b-4473-b3cc-f8d901f41208', 'S7-5', 'Code of conduct cascaded to all direct suppliers with annual attestation; 12 third-party SMETA audits in the last 24 months; corrective actions tracked to closure.', null, '2026-07-06T14:30:00Z', '2026-07-06T14:30:00Z'),
  ('607a321f-563b-4fb6-aa89-b6b5be2760cf', 'S1-1', 'Advanced Precision s.r.o., Czechia', null, '2026-06-11T14:30:00Z', '2026-06-11T14:30:00Z'),
  ('607a321f-563b-4fb6-aa89-b6b5be2760cf', 'S1-2', 'Petra Dvorak, ESG Coordinator, petra.dvorak.advancedprecision@example.com', null, '2026-06-11T14:30:00Z', '2026-06-11T14:30:00Z'),
  ('607a321f-563b-4fb6-aa89-b6b5be2760cf', 'S1-3', 'No — Will Complete Questionnaire', null, '2026-06-11T14:30:00Z', '2026-06-11T14:30:00Z'),
  ('607a321f-563b-4fb6-aa89-b6b5be2760cf', 'S1-4', null, null, '2026-06-11T14:30:00Z', '2026-06-11T14:30:00Z'),
  ('607a321f-563b-4fb6-aa89-b6b5be2760cf', 'S2-1', '95370', 'ISO 14064-3 limited assurance', '2026-06-11T14:30:00Z', '2026-06-11T14:30:00Z'),
  ('607a321f-563b-4fb6-aa89-b6b5be2760cf', 'S2-2', '85811', null, '2026-06-11T14:30:00Z', '2026-06-11T14:30:00Z'),
  ('607a321f-563b-4fb6-aa89-b6b5be2760cf', 'S2-3', '1064408', 'Cat 1,3,4,5,6,7', '2026-06-11T14:30:00Z', '2026-06-11T14:30:00Z'),
  ('607a321f-563b-4fb6-aa89-b6b5be2760cf', 'S2-4', 'Yes', null, '2026-06-11T14:30:00Z', '2026-06-11T14:30:00Z'),
  ('607a321f-563b-4fb6-aa89-b6b5be2760cf', 'S2-5', '1) On-site solar feasibility study underway (83% renewable share today). 2) Compressed air leak programme, est. 400 tCO2e/yr. 3) LED retrofit completed 2025.', null, '2026-06-11T14:30:00Z', '2026-06-11T14:30:00Z'),
  ('607a321f-563b-4fb6-aa89-b6b5be2760cf', 'S2-6', 'Capex competition with capacity expansion; limited access to green financing; renewable tariffs not yet available at our grid location.', null, '2026-06-11T14:30:00Z', '2026-06-11T14:30:00Z'),
  ('607a321f-563b-4fb6-aa89-b6b5be2760cf', 'S3-1', '0', null, '2026-06-11T14:30:00Z', '2026-06-11T14:30:00Z'),
  ('607a321f-563b-4fb6-aa89-b6b5be2760cf', 'S3-2', 'No', null, '2026-06-11T14:30:00Z', '2026-06-11T14:30:00Z'),
  ('607a321f-563b-4fb6-aa89-b6b5be2760cf', 'S3-3', null, null, '2026-06-11T14:30:00Z', '2026-06-11T14:30:00Z'),
  ('607a321f-563b-4fb6-aa89-b6b5be2760cf', 'S3-4', 'Primary treatment on site, discharge to municipal treatment under permit. Quarterly third-party sampling for heavy metals and COD.', null, '2026-06-11T14:30:00Z', '2026-06-11T14:30:00Z'),
  ('607a321f-563b-4fb6-aa89-b6b5be2760cf', 'S4-1', '425624', 'Groundwater', '2026-06-11T14:30:00Z', '2026-06-11T14:30:00Z'),
  ('607a321f-563b-4fb6-aa89-b6b5be2760cf', 'S4-2', 'No', null, '2026-06-11T14:30:00Z', '2026-06-11T14:30:00Z'),
  ('607a321f-563b-4fb6-aa89-b6b5be2760cf', 'S4-3', 'Cooling tower blowdown recovery installed 2025. Intensity roughly flat over three years; metering upgraded in 2024.', null, '2026-06-11T14:30:00Z', '2026-06-11T14:30:00Z'),
  ('607a321f-563b-4fb6-aa89-b6b5be2760cf', 'S4-4', null, null, '2026-06-11T14:30:00Z', '2026-06-11T14:30:00Z'),
  ('607a321f-563b-4fb6-aa89-b6b5be2760cf', 'S5-1', '7330', 'Breakdown: landfill 413, recycled 2510, energy recovery 733, hazardous 797.', '2026-06-11T14:30:00Z', '2026-06-11T14:30:00Z'),
  ('607a321f-563b-4fb6-aa89-b6b5be2760cf', 'S5-2', '21', null, '2026-06-11T14:30:00Z', '2026-06-11T14:30:00Z'),
  ('607a321f-563b-4fb6-aa89-b6b5be2760cf', 'S5-3', 'Increasing PCR share in housings; regrind of internal scrap into non-cosmetic parts.', null, '2026-06-11T14:30:00Z', '2026-06-11T14:30:00Z'),
  ('607a321f-563b-4fb6-aa89-b6b5be2760cf', 'S5-4', 'Diversion around 70%. Main streams: mixed plastics and packaging to recycling; hazardous sludge to licensed treatment. Evaluating waste-to-energy for residuals.', null, '2026-06-11T14:30:00Z', '2026-06-11T14:30:00Z'),
  ('607a321f-563b-4fb6-aa89-b6b5be2760cf', 'S6-1', 'Yes', null, '2026-06-11T14:30:00Z', '2026-06-11T14:30:00Z'),
  ('607a321f-563b-4fb6-aa89-b6b5be2760cf', 'S6-2', 'Landscaping with native species; light curfew on non-production areas.', null, '2026-06-11T14:30:00Z', '2026-06-11T14:30:00Z'),
  ('607a321f-563b-4fb6-aa89-b6b5be2760cf', 'S6-3', 'No. Target date: Q4 2027.', null, '2026-06-11T14:30:00Z', '2026-06-11T14:30:00Z'),
  ('607a321f-563b-4fb6-aa89-b6b5be2760cf', 'S7-1', 'Yes', null, '2026-06-11T14:30:00Z', '2026-06-11T14:30:00Z'),
  ('607a321f-563b-4fb6-aa89-b6b5be2760cf', 'S7-2', 'Yes', null, '2026-06-11T14:30:00Z', '2026-06-11T14:30:00Z'),
  ('607a321f-563b-4fb6-aa89-b6b5be2760cf', 'S7-3', 'Suggestion boxes and HR open-door process. 3 grievances filed, 3 resolved in the last 12 months.', null, '2026-06-11T14:30:00Z', '2026-06-11T14:30:00Z'),
  ('607a321f-563b-4fb6-aa89-b6b5be2760cf', 'S7-4', 'No', null, '2026-06-11T14:30:00Z', '2026-06-11T14:30:00Z'),
  ('607a321f-563b-4fb6-aa89-b6b5be2760cf', 'S7-5', 'Code of conduct signed by key suppliers at onboarding; 2 third-party audits in the last 24 months.', null, '2026-06-11T14:30:00Z', '2026-06-11T14:30:00Z'),
  ('1e08ddaa-8e12-4dce-9be8-3f9268f86caa', 'S1-1', 'Beta Chemicals Co. Ltd., Taiwan', null, '2026-07-05T14:30:00Z', '2026-07-05T14:30:00Z'),
  ('1e08ddaa-8e12-4dce-9be8-3f9268f86caa', 'S1-2', 'Chien Lin, ESG Coordinator, chien.lin.betachemicals@example.com', null, '2026-07-05T14:30:00Z', '2026-07-05T14:30:00Z'),
  ('1e08ddaa-8e12-4dce-9be8-3f9268f86caa', 'S1-3', 'No — Will Complete Questionnaire', null, '2026-07-05T14:30:00Z', '2026-07-05T14:30:00Z'),
  ('1e08ddaa-8e12-4dce-9be8-3f9268f86caa', 'S1-4', null, null, '2026-07-05T14:30:00Z', '2026-07-05T14:30:00Z'),
  ('1e08ddaa-8e12-4dce-9be8-3f9268f86caa', 'S2-1', '46310', 'Internal estimate', '2026-07-05T14:30:00Z', '2026-07-05T14:30:00Z'),
  ('1e08ddaa-8e12-4dce-9be8-3f9268f86caa', 'S2-2', '30855', null, '2026-07-05T14:30:00Z', '2026-07-05T14:30:00Z'),
  ('1e08ddaa-8e12-4dce-9be8-3f9268f86caa', 'S2-3', '223919', 'Cat 1,4 only', '2026-07-05T14:30:00Z', '2026-07-05T14:30:00Z'),
  ('1e08ddaa-8e12-4dce-9be8-3f9268f86caa', 'S2-4', 'No', null, '2026-07-05T14:30:00Z', '2026-07-05T14:30:00Z'),
  ('1e08ddaa-8e12-4dce-9be8-3f9268f86caa', 'S2-5', 'Energy efficiency audit planned for 2027. No quantified projects yet.', null, '2026-07-05T14:30:00Z', '2026-07-05T14:30:00Z'),
  ('1e08ddaa-8e12-4dce-9be8-3f9268f86caa', 'S2-6', 'No dedicated sustainability budget or headcount. Awaiting customer requirements before committing capex.', null, '2026-07-05T14:30:00Z', '2026-07-05T14:30:00Z'),
  ('1e08ddaa-8e12-4dce-9be8-3f9268f86caa', 'S3-1', '0', null, '2026-07-05T14:30:00Z', '2026-07-05T14:30:00Z'),
  ('1e08ddaa-8e12-4dce-9be8-3f9268f86caa', 'S3-2', 'No', null, '2026-07-05T14:30:00Z', '2026-07-05T14:30:00Z'),
  ('1e08ddaa-8e12-4dce-9be8-3f9268f86caa', 'S3-3', null, null, '2026-07-05T14:30:00Z', '2026-07-05T14:30:00Z'),
  ('1e08ddaa-8e12-4dce-9be8-3f9268f86caa', 'S3-4', 'Discharge to municipal system under local permit. No additional on-site treatment.', null, '2026-07-05T14:30:00Z', '2026-07-05T14:30:00Z'),
  ('1e08ddaa-8e12-4dce-9be8-3f9268f86caa', 'S4-1', '647852', 'Municipal', '2026-07-05T14:30:00Z', '2026-07-05T14:30:00Z'),
  ('1e08ddaa-8e12-4dce-9be8-3f9268f86caa', 'S4-2', 'No', null, '2026-07-05T14:30:00Z', '2026-07-05T14:30:00Z'),
  ('1e08ddaa-8e12-4dce-9be8-3f9268f86caa', 'S4-3', 'None implemented. Intensity not tracked at unit level.', null, '2026-07-05T14:30:00Z', '2026-07-05T14:30:00Z'),
  ('1e08ddaa-8e12-4dce-9be8-3f9268f86caa', 'S4-4', null, null, '2026-07-05T14:30:00Z', '2026-07-05T14:30:00Z'),
  ('1e08ddaa-8e12-4dce-9be8-3f9268f86caa', 'S5-1', null, null, '2026-07-05T14:30:00Z', '2026-07-05T14:30:00Z'),
  ('1e08ddaa-8e12-4dce-9be8-3f9268f86caa', 'S5-2', '7', null, '2026-07-05T14:30:00Z', '2026-07-05T14:30:00Z'),
  ('1e08ddaa-8e12-4dce-9be8-3f9268f86caa', 'S5-3', 'No specific circularity measures for supplied components at this time.', null, '2026-07-05T14:30:00Z', '2026-07-05T14:30:00Z'),
  ('1e08ddaa-8e12-4dce-9be8-3f9268f86caa', 'S5-4', 'Waste segregated per legal requirements; majority of residual waste to landfill. No ZWTL target.', null, '2026-07-05T14:30:00Z', '2026-07-05T14:30:00Z'),
  ('1e08ddaa-8e12-4dce-9be8-3f9268f86caa', 'S6-1', 'Yes', null, '2026-07-05T14:30:00Z', '2026-07-05T14:30:00Z'),
  ('1e08ddaa-8e12-4dce-9be8-3f9268f86caa', 'S6-2', 'None.', null, '2026-07-05T14:30:00Z', '2026-07-05T14:30:00Z'),
  ('1e08ddaa-8e12-4dce-9be8-3f9268f86caa', 'S6-3', 'No. No assessment planned.', null, '2026-07-05T14:30:00Z', '2026-07-05T14:30:00Z'),
  ('1e08ddaa-8e12-4dce-9be8-3f9268f86caa', 'S7-1', 'No', null, '2026-07-05T14:30:00Z', '2026-07-05T14:30:00Z'),
  ('1e08ddaa-8e12-4dce-9be8-3f9268f86caa', 'S7-2', 'No', null, '2026-07-05T14:30:00Z', '2026-07-05T14:30:00Z'),
  ('1e08ddaa-8e12-4dce-9be8-3f9268f86caa', 'S7-3', 'Workers may raise issues with supervisors. No formal count kept.', null, '2026-07-05T14:30:00Z', '2026-07-05T14:30:00Z'),
  ('1e08ddaa-8e12-4dce-9be8-3f9268f86caa', 'S7-4', 'No', null, '2026-07-05T14:30:00Z', '2026-07-05T14:30:00Z'),
  ('1e08ddaa-8e12-4dce-9be8-3f9268f86caa', 'S7-5', 'Code of conduct available on request; compliance monitored informally. No third-party audits in the last 24 months.', null, '2026-07-05T14:30:00Z', '2026-07-05T14:30:00Z'),
  ('bcf3b126-e05a-45f5-8760-5d134e17fc7f', 'S1-1', 'Quantum Materials Sdn. Bhd., Malaysia', null, '2026-06-19T14:30:00Z', '2026-06-19T14:30:00Z'),
  ('bcf3b126-e05a-45f5-8760-5d134e17fc7f', 'S1-2', 'Wei Lee, ESG Coordinator, wei.lee.quantummaterials@example.com', null, '2026-06-19T14:30:00Z', '2026-06-19T14:30:00Z'),
  ('bcf3b126-e05a-45f5-8760-5d134e17fc7f', 'S1-3', 'No — Will Complete Questionnaire', null, '2026-06-19T14:30:00Z', '2026-06-19T14:30:00Z'),
  ('bcf3b126-e05a-45f5-8760-5d134e17fc7f', 'S1-4', null, null, '2026-06-19T14:30:00Z', '2026-06-19T14:30:00Z'),
  ('bcf3b126-e05a-45f5-8760-5d134e17fc7f', 'S2-1', '93277', 'ISO 14064-3 limited assurance', '2026-06-19T14:30:00Z', '2026-06-19T14:30:00Z'),
  ('bcf3b126-e05a-45f5-8760-5d134e17fc7f', 'S2-2', '82895', null, '2026-06-19T14:30:00Z', '2026-06-19T14:30:00Z'),
  ('bcf3b126-e05a-45f5-8760-5d134e17fc7f', 'S2-3', null, null, '2026-06-19T14:30:00Z', '2026-06-19T14:30:00Z'),
  ('bcf3b126-e05a-45f5-8760-5d134e17fc7f', 'S2-4', 'No', null, '2026-06-19T14:30:00Z', '2026-06-19T14:30:00Z'),
  ('bcf3b126-e05a-45f5-8760-5d134e17fc7f', 'S2-5', '1) On-site solar feasibility study underway (31% renewable share today). 2) Compressed air leak programme, est. 400 tCO2e/yr. 3) LED retrofit completed 2025. Group reduction target 2030.', null, '2026-06-19T14:30:00Z', '2026-06-19T14:30:00Z'),
  ('bcf3b126-e05a-45f5-8760-5d134e17fc7f', 'S2-6', 'Capex competition with capacity expansion; limited access to green financing; renewable tariffs not yet available at our grid location.', null, '2026-06-19T14:30:00Z', '2026-06-19T14:30:00Z'),
  ('bcf3b126-e05a-45f5-8760-5d134e17fc7f', 'S3-1', '9441', null, '2026-06-19T14:30:00Z', '2026-06-19T14:30:00Z'),
  ('bcf3b126-e05a-45f5-8760-5d134e17fc7f', 'S3-2', 'Yes', null, '2026-06-19T14:30:00Z', '2026-06-19T14:30:00Z'),
  ('bcf3b126-e05a-45f5-8760-5d134e17fc7f', 'S3-3', 'Alternatives under evaluation with coating supplier; no validated substitute yet. Target phase-out: 2029.', null, '2026-06-19T14:30:00Z', '2026-06-19T14:30:00Z'),
  ('bcf3b126-e05a-45f5-8760-5d134e17fc7f', 'S3-4', 'Primary treatment on site, discharge to municipal treatment under permit. Quarterly third-party sampling for heavy metals and COD.', null, '2026-06-19T14:30:00Z', '2026-06-19T14:30:00Z'),
  ('bcf3b126-e05a-45f5-8760-5d134e17fc7f', 'S4-1', '704697', 'Municipal + groundwater', '2026-06-19T14:30:00Z', '2026-06-19T14:30:00Z'),
  ('bcf3b126-e05a-45f5-8760-5d134e17fc7f', 'S4-2', 'Yes', null, '2026-06-19T14:30:00Z', '2026-06-19T14:30:00Z'),
  ('bcf3b126-e05a-45f5-8760-5d134e17fc7f', 'S4-3', 'Cooling tower blowdown recovery installed 2025. Intensity roughly flat over three years; metering upgraded in 2024.', null, '2026-06-19T14:30:00Z', '2026-06-19T14:30:00Z'),
  ('bcf3b126-e05a-45f5-8760-5d134e17fc7f', 'S4-4', 'Under development, due 2027.', null, '2026-06-19T14:30:00Z', '2026-06-19T14:30:00Z'),
  ('bcf3b126-e05a-45f5-8760-5d134e17fc7f', 'S5-1', '6485', 'Breakdown: landfill 1871, recycled 3983, energy recovery 648, hazardous 465.', '2026-06-19T14:30:00Z', '2026-06-19T14:30:00Z'),
  ('bcf3b126-e05a-45f5-8760-5d134e17fc7f', 'S5-2', '14', null, '2026-06-19T14:30:00Z', '2026-06-19T14:30:00Z'),
  ('bcf3b126-e05a-45f5-8760-5d134e17fc7f', 'S5-3', 'Increasing PCR share in housings; regrind of internal scrap into non-cosmetic parts.', null, '2026-06-19T14:30:00Z', '2026-06-19T14:30:00Z'),
  ('bcf3b126-e05a-45f5-8760-5d134e17fc7f', 'S5-4', 'Diversion around 70%. Main streams: mixed plastics and packaging to recycling; hazardous sludge to licensed treatment. Evaluating waste-to-energy for residuals.', null, '2026-06-19T14:30:00Z', '2026-06-19T14:30:00Z'),
  ('bcf3b126-e05a-45f5-8760-5d134e17fc7f', 'S6-1', 'Yes', null, '2026-06-19T14:30:00Z', '2026-06-19T14:30:00Z'),
  ('bcf3b126-e05a-45f5-8760-5d134e17fc7f', 'S6-2', 'Landscaping with native species; light curfew on non-production areas.', null, '2026-06-19T14:30:00Z', '2026-06-19T14:30:00Z'),
  ('bcf3b126-e05a-45f5-8760-5d134e17fc7f', 'S6-3', 'No. Target date: Q4 2027.', null, '2026-06-19T14:30:00Z', '2026-06-19T14:30:00Z'),
  ('bcf3b126-e05a-45f5-8760-5d134e17fc7f', 'S7-1', 'Yes', null, '2026-06-19T14:30:00Z', '2026-06-19T14:30:00Z'),
  ('bcf3b126-e05a-45f5-8760-5d134e17fc7f', 'S7-2', 'No', null, '2026-06-19T14:30:00Z', '2026-06-19T14:30:00Z'),
  ('bcf3b126-e05a-45f5-8760-5d134e17fc7f', 'S7-3', 'Suggestion boxes and HR open-door process. 3 grievances filed, 3 resolved in the last 12 months.', null, '2026-06-19T14:30:00Z', '2026-06-19T14:30:00Z'),
  ('bcf3b126-e05a-45f5-8760-5d134e17fc7f', 'S7-4', 'No', null, '2026-06-19T14:30:00Z', '2026-06-19T14:30:00Z'),
  ('bcf3b126-e05a-45f5-8760-5d134e17fc7f', 'S7-5', 'Code of conduct signed by key suppliers at onboarding; 2 third-party audits in the last 24 months.', null, '2026-06-19T14:30:00Z', '2026-06-19T14:30:00Z'),
  ('2acf39ba-4ccb-47d2-be6b-2e80a0ab2982', 'S1-1', 'Pinnacle Power Co. Ltd., Vietnam', null, '2026-06-28T14:30:00Z', '2026-06-28T14:30:00Z'),
  ('2acf39ba-4ccb-47d2-be6b-2e80a0ab2982', 'S1-2', 'Tuan Nguyen, ESG Coordinator, tuan.nguyen.pinnaclepower@example.com', null, '2026-06-28T14:30:00Z', '2026-06-28T14:30:00Z'),
  ('2acf39ba-4ccb-47d2-be6b-2e80a0ab2982', 'S1-3', 'No — Will Complete Questionnaire', null, '2026-06-28T14:30:00Z', '2026-06-28T14:30:00Z'),
  ('2acf39ba-4ccb-47d2-be6b-2e80a0ab2982', 'S1-4', null, null, '2026-06-28T14:30:00Z', '2026-06-28T14:30:00Z'),
  ('2acf39ba-4ccb-47d2-be6b-2e80a0ab2982', 'S2-1', '43118', 'Third-party verified', '2026-06-28T14:30:00Z', '2026-06-28T14:30:00Z'),
  ('2acf39ba-4ccb-47d2-be6b-2e80a0ab2982', 'S2-2', '65186', null, '2026-06-28T14:30:00Z', '2026-06-28T14:30:00Z'),
  ('2acf39ba-4ccb-47d2-be6b-2e80a0ab2982', 'S2-3', '599259', 'Cat 1,3,4,5,6,7', '2026-06-28T14:30:00Z', '2026-06-28T14:30:00Z'),
  ('2acf39ba-4ccb-47d2-be6b-2e80a0ab2982', 'S2-4', 'No', null, '2026-06-28T14:30:00Z', '2026-06-28T14:30:00Z'),
  ('2acf39ba-4ccb-47d2-be6b-2e80a0ab2982', 'S2-5', '1) On-site solar feasibility study underway (28% renewable share today). 2) Compressed air leak programme, est. 400 tCO2e/yr. 3) LED retrofit completed 2025.', null, '2026-06-28T14:30:00Z', '2026-06-28T14:30:00Z'),
  ('2acf39ba-4ccb-47d2-be6b-2e80a0ab2982', 'S2-6', 'Capex competition with capacity expansion; limited access to green financing; renewable tariffs not yet available at our grid location.', null, '2026-06-28T14:30:00Z', '2026-06-28T14:30:00Z'),
  ('2acf39ba-4ccb-47d2-be6b-2e80a0ab2982', 'S3-1', '373', null, '2026-06-28T14:30:00Z', '2026-06-28T14:30:00Z'),
  ('2acf39ba-4ccb-47d2-be6b-2e80a0ab2982', 'S3-2', 'No', null, '2026-06-28T14:30:00Z', '2026-06-28T14:30:00Z'),
  ('2acf39ba-4ccb-47d2-be6b-2e80a0ab2982', 'S3-3', null, null, '2026-06-28T14:30:00Z', '2026-06-28T14:30:00Z'),
  ('2acf39ba-4ccb-47d2-be6b-2e80a0ab2982', 'S3-4', 'Primary treatment on site, discharge to municipal treatment under permit. Quarterly third-party sampling for heavy metals and COD.', null, '2026-06-28T14:30:00Z', '2026-06-28T14:30:00Z'),
  ('2acf39ba-4ccb-47d2-be6b-2e80a0ab2982', 'S4-1', '158031', 'Groundwater', '2026-06-28T14:30:00Z', '2026-06-28T14:30:00Z'),
  ('2acf39ba-4ccb-47d2-be6b-2e80a0ab2982', 'S4-2', 'No', null, '2026-06-28T14:30:00Z', '2026-06-28T14:30:00Z'),
  ('2acf39ba-4ccb-47d2-be6b-2e80a0ab2982', 'S4-3', 'Cooling tower blowdown recovery installed 2025. Intensity roughly flat over three years; metering upgraded in 2024.', null, '2026-06-28T14:30:00Z', '2026-06-28T14:30:00Z'),
  ('2acf39ba-4ccb-47d2-be6b-2e80a0ab2982', 'S4-4', null, null, '2026-06-28T14:30:00Z', '2026-06-28T14:30:00Z'),
  ('2acf39ba-4ccb-47d2-be6b-2e80a0ab2982', 'S5-1', '2803', 'Breakdown: landfill 701, recycled 1432, energy recovery 280, hazardous 203.', '2026-06-28T14:30:00Z', '2026-06-28T14:30:00Z'),
  ('2acf39ba-4ccb-47d2-be6b-2e80a0ab2982', 'S5-2', '23', null, '2026-06-28T14:30:00Z', '2026-06-28T14:30:00Z'),
  ('2acf39ba-4ccb-47d2-be6b-2e80a0ab2982', 'S5-3', 'Increasing PCR share in housings; regrind of internal scrap into non-cosmetic parts.', null, '2026-06-28T14:30:00Z', '2026-06-28T14:30:00Z'),
  ('2acf39ba-4ccb-47d2-be6b-2e80a0ab2982', 'S5-4', 'Diversion around 70%. Main streams: mixed plastics and packaging to recycling; hazardous sludge to licensed treatment. Evaluating waste-to-energy for residuals.', null, '2026-06-28T14:30:00Z', '2026-06-28T14:30:00Z'),
  ('2acf39ba-4ccb-47d2-be6b-2e80a0ab2982', 'S6-1', 'Yes', null, '2026-06-28T14:30:00Z', '2026-06-28T14:30:00Z'),
  ('2acf39ba-4ccb-47d2-be6b-2e80a0ab2982', 'S6-2', 'Landscaping with native species; light curfew on non-production areas.', null, '2026-06-28T14:30:00Z', '2026-06-28T14:30:00Z'),
  ('2acf39ba-4ccb-47d2-be6b-2e80a0ab2982', 'S6-3', 'No. Target date: Q4 2027.', null, '2026-06-28T14:30:00Z', '2026-06-28T14:30:00Z'),
  ('2acf39ba-4ccb-47d2-be6b-2e80a0ab2982', 'S7-1', 'Yes', null, '2026-06-28T14:30:00Z', '2026-06-28T14:30:00Z'),
  ('2acf39ba-4ccb-47d2-be6b-2e80a0ab2982', 'S7-2', 'Yes', null, '2026-06-28T14:30:00Z', '2026-06-28T14:30:00Z'),
  ('2acf39ba-4ccb-47d2-be6b-2e80a0ab2982', 'S7-3', 'Suggestion boxes and HR open-door process. 3 grievances filed, 3 resolved in the last 12 months.', null, '2026-06-28T14:30:00Z', '2026-06-28T14:30:00Z'),
  ('2acf39ba-4ccb-47d2-be6b-2e80a0ab2982', 'S7-4', 'No', null, '2026-06-28T14:30:00Z', '2026-06-28T14:30:00Z'),
  ('2acf39ba-4ccb-47d2-be6b-2e80a0ab2982', 'S7-5', 'Code of conduct signed by key suppliers at onboarding; 2 third-party audits in the last 24 months.', null, '2026-06-28T14:30:00Z', '2026-06-28T14:30:00Z');

commit;

-- MAPPING: question id <- workbook key (order matches site/js/questions.js)
--   S1-1  <- company_name + ', ' + country (from s1_legal_name)
--   S1-2  <- contact name, title, email (from s1_contact)
--   S1-3  <- fixed: No — Will Complete Questionnaire
--   S1-4  <- s1_ecovadis_link
--   S2-1  <- s2_scope1_tco2e   (evidence_note <- s2_scope1_verification)
--   S2-2  <- s2_scope2_tco2e
--   S2-3  <- s2_scope3_tco2e   (evidence_note <- s2_scope3_categories)
--   S2-4  <- s2_sbti
--   S2-5  <- s2_decarb_projects
--   S2-6  <- s2_barriers
--   S3-1  <- s3_svhc_kg
--   S3-2  <- s3_pfas
--   S3-3  <- s3_pfas_roadmap
--   S3-4  <- s3_wastewater
--   S4-1  <- s4_withdrawal_m3   (evidence_note <- s4_withdrawal_source)
--   S4-2  <- s4_water_stress
--   S4-3  <- s4_water_projects
--   S4-4  <- s4_drought_plan
--   S5-1  <- s5_waste_tonnes
--   S5-2  <- s5_pcr_pct
--   S5-3  <- s5_circularity
--   S5-4  <- s5_zwtl
--   S6-1  <- s6_protected_area
--   S6-2  <- s6_biodiversity_initiatives
--   S6-3  <- s6_tnfd
--   S7-1  <- s7_hr_policy
--   S7-2  <- s7_hrdd
--   S7-3  <- s7_grievance
--   S7-4  <- s7_conflict_minerals
--   S7-5  <- s7_coc
-- The workbook's doors (door_1_guided, door_2_upload) are all seeded as route 'form' (decided 19 Nov):
-- an 'upload' row would need a real file in the private bucket.

-- REMOVE THE SEED (run only when Zyad asks)
-- begin;
-- delete from public.submission_answers
--   where submission_id in (select id from public.submissions where contact_email like '%@example.com');
-- delete from public.submissions where contact_email like '%@example.com';
-- commit;
