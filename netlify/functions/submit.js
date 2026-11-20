// submit: the only write path into the database (docs/access-matrix.md Section 6, lines 1, 3 and 5).
// It holds the secret key, so RLS does not apply to it: it validates every field itself and does nothing
// except the validated inserts and the supersede step (through create_submission).
// Since v2.1 it stores no file and refuses any request that carries one: an uploaded workbook is only
// read by parse-workbook, and the answers the supplier confirms are the submission.
// It never stores or logs the visitor's IP.
'use strict';

const crypto = require('crypto');
const { createClient } = require('@supabase/supabase-js');
const { validateSubmission } = require('../lib/validate.js');
const { json, readBody } = require('../lib/http.js');

const MAX_REQUEST_BYTES = 300 * 1024; // the fields and the answers; no file travels here
const SAVE_ERROR = 'We could not save your submission. Nothing was recorded. Please try again.';
const MONTHS = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
const FILE_KEYS = ['file', 'fileBase64', 'fileName', 'file_path'];

function displayDate(iso) {
  const d = new Date(iso);
  return d.getUTCDate() + ' ' + MONTHS[d.getUTCMonth()] + ' ' + d.getUTCFullYear();
}

function supabaseUrl() {
  // Names written by the Netlify Supabase extension; values are never in code.
  const candidates = [process.env.SUPABASE_URL, process.env.VITE_SUPABASE_URL, process.env.SUPABASE_DATABASE_URL];
  return candidates.find((u) => typeof u === 'string' && /^https:\/\//.test(u)) || '';
}

exports.handler = async (event) => {
  if (event.httpMethod !== 'POST') return json(405, { error: 'Method not allowed.' });

  const { data, error } = readBody(event, MAX_REQUEST_BYTES);
  if (error) return error.statusCode === 413 ? json(413, { error: 'The submission is too large.' }) : error;
  if (!data || typeof data !== 'object' || Array.isArray(data)) return json(400, { error: 'The request could not be read.' });

  if (FILE_KEYS.some((k) => k in data)) {
    return json(400, { error: 'Files are not accepted here. Only your confirmed answers are submitted. Nothing was recorded.' });
  }

  const { value, errors } = validateSubmission(data);
  if (errors) return json(400, { error: 'Please check the highlighted fields.', fields: errors });

  const url = supabaseUrl();
  const key = process.env.SUPABASE_SERVICE_ROLE_KEY;
  if (!url || !key) {
    console.error('submit: Supabase environment variables are missing');
    return json(500, { error: SAVE_ERROR });
  }
  const db = createClient(url, key, { auth: { persistSession: false, autoRefreshToken: false } });

  const id = crypto.randomUUID();
  const { data: rows, error: rpcError } = await db.rpc('create_submission', { payload: { ...value, id } });
  if (rpcError || !rows || !rows.length) {
    console.error('submit: create_submission failed', rpcError && rpcError.message);
    return json(500, { error: SAVE_ERROR });
  }

  return json(200, {
    reference: id.slice(0, 8).toUpperCase(),
    date: displayDate(rows[0].submitted_at),
    company_name: value.company_name,
  });
};
