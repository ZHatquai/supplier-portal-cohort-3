// Validates a submission exactly as product-spec.md v2.0 Sections 5 and 9 state it.
// Returns { errors } (field -> message) or { value } (the cleaned payload for create_submission).
'use strict';

const Q = require('../../site/js/questions.js');

const QUESTION_IDS = new Set(Q.questions.map((q) => q.id));
const ROUTES = new Set(['ecovadis', 'form', 'upload']);
const MAX_TEXT = 4000;
const S1_3_FORM_VALUE = (Q.questions.find((q) => q.id === 'S1-3').options || []).find((o) => /^No/.test(o));

const LABELS = {
  company_name: 'company name',
  company_country: 'country',
  contact_name: 'contact name',
  contact_email: 'contact email',
  declaration_name: 'authorised signatory name',
  declaration_date: 'declaration date',
};

function str(v) {
  return typeof v === 'string' ? v.trim() : '';
}

function validDate(s) {
  if (!/^\d{4}-\d{2}-\d{2}$/.test(s)) return false;
  const d = new Date(s + 'T00:00:00Z');
  return !Number.isNaN(d.getTime()) && d.toISOString().slice(0, 10) === s;
}

function companyKey(name, email) {
  return name.toLowerCase().replace(/\s+/g, ' ').trim() + '|' + email.toLowerCase().trim();
}

function validateSubmission(body) {
  const errors = {};
  const route = str(body.route);
  if (!ROUTES.has(route)) return { errors: { route: 'Choose a route.' } };
  const full = route !== 'ecovadis';

  const v = {
    route,
    company_name: str(body.company_name),
    company_country: str(body.company_country),
    contact_name: str(body.contact_name),
    contact_title: str(body.contact_title),
    contact_email: str(body.contact_email),
    ecovadis_link: str(body.ecovadis_link),
    declaration_name: str(body.declaration_name),
    declaration_date: str(body.declaration_date),
    declaration_confirmed: body.declaration_confirmed === true,
  };

  const required = ['company_name', 'contact_name', 'contact_email'];
  if (full) required.push('company_country', 'declaration_name', 'declaration_date');
  for (const f of required) if (!v[f]) errors[f] = 'Enter ' + LABELS[f] + '.';

  const limits = { company_name: 300, company_country: 200, contact_name: 200, contact_title: 200, contact_email: 320, ecovadis_link: 2000, declaration_name: 200 };
  for (const [f, max] of Object.entries(limits)) if (v[f].length > max && !errors[f]) errors[f] = 'This answer is too long.';

  if (v.contact_email && !errors.contact_email && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(v.contact_email)) {
    errors.contact_email = 'Enter a valid email address.';
  }
  if (v.ecovadis_link && !errors.ecovadis_link && !/^https?:\/\/\S+$/i.test(v.ecovadis_link)) {
    errors.ecovadis_link = 'Enter a link that starts with https://';
  }
  if (full) {
    if (v.declaration_date && !validDate(v.declaration_date)) errors.declaration_date = 'Enter the declaration date.';
    if (!v.declaration_confirmed) errors.declaration_confirmed = 'Confirm that the information is accurate and complete.';
  } else {
    v.company_country = '';
    v.declaration_name = '';
    v.declaration_date = '';
    v.declaration_confirmed = false;
  }

  // answers: only the 30 known ids, once each, at most 4,000 characters
  const answers = [];
  if (full) {
    const given = Array.isArray(body.answers) ? body.answers : null;
    if (!given) {
      errors.answers = 'The answers are missing.';
    } else {
      const seen = new Set();
      for (const a of given) {
        const id = a && typeof a.question_id === 'string' ? a.question_id : '';
        if (!QUESTION_IDS.has(id) || seen.has(id)) { errors.answers = 'The answers could not be read.'; break; }
        seen.add(id);
        const response = typeof a.response === 'string' ? a.response.trim() : '';
        const note = typeof a.evidence_note === 'string' ? a.evidence_note.trim() : '';
        if (response.length > MAX_TEXT || note.length > MAX_TEXT) { errors['answer_' + id] = 'This answer is too long. The limit is 4,000 characters.'; continue; }
        answers.push({ question_id: id, response, evidence_note: note });
      }
      if (!errors.answers) {
        // S1-1 and S1-2 are composed from the confirmed fields; S1-3 is fixed on the form
        const byId = new Map(answers.map((a) => [a.question_id, a]));
        const set = (id, response) => {
          const a = byId.get(id) || { question_id: id, response: '', evidence_note: '' };
          a.response = response;
          byId.set(id, a);
        };
        set('S1-1', [v.company_name, v.company_country].filter(Boolean).join(', '));
        set('S1-2', [v.contact_name, v.contact_title, v.contact_email].filter(Boolean).join(', '));
        if (route === 'form' && S1_3_FORM_VALUE) set('S1-3', S1_3_FORM_VALUE);
        answers.length = 0;
        for (const q of Q.questions) answers.push(byId.get(q.id) || { question_id: q.id, response: '', evidence_note: '' });
      }
    }
  } else if (Array.isArray(body.answers) && body.answers.length) {
    errors.answers = 'The EcoVadis route takes no answers.';
  }

  if (Object.keys(errors).length) return { errors };
  v.company_key = companyKey(v.company_name, v.contact_email);
  v.answers = answers;
  return { value: v };
}

module.exports = { validateSubmission, companyKey };
