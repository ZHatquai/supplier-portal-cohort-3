// submit: the only write path into the database (docs/access-matrix.md Section 6, lines 1, 3 and 5).
// It holds the secret key, so RLS does not apply to it: it validates every field itself and does nothing
// except the validated inserts (through create_submission), the supersede step and the file upload.
// It never stores or logs the visitor's IP.
'use strict';

const crypto = require('crypto');
const { createClient } = require('@supabase/supabase-js');
const { validateSubmission } = require('../lib/validate.js');
const { readWorkbook, ReadError, MAX_FILE_BYTES } = require('../lib/workbook.js');
const { json, readBody } = require('../lib/http.js');

const MAX_FIELDS_BYTES = 300 * 1024;              // the form fields and answers
const MAX_REQUEST_BYTES = 5.8 * 1024 * 1024;      // fields plus a 4 MB file, base64-encoded
const SAVE_ERROR = 'We could not save your submission. Nothing was recorded. Please try again.';
const XLSX_TYPE = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
const MONTHS = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];

function displayDate(iso) {
  const d = new Date(iso);
  return d.getUTCDate() + ' ' + MONTHS[d.getUTCMonth()] + ' ' + d.getUTCFullYear();
}

function supabaseUrl() {
  // Names written by the Netlify Supabase extension; values are never in code.
  const candidates = [process.env.SUPABASE_URL, process.env.VITE_SUPABASE_URL, process.env.SUPABASE_DATABASE_URL];
  return candidates.find((u) => typeof u === 'string' && /^https:\/\//.test(u)) || '';
}

function safeFileName(name) {
  const base = String(name || 'questionnaire.xlsx').split(/[\\/]/).pop();
  const cleaned = base.replace(/[^A-Za-z0-9._ -]/g, '_').replace(/\s+/g, ' ').trim().slice(0, 120);
  return /\.xlsx$/i.test(cleaned) ? cleaned : 'questionnaire.xlsx';
}

exports.handler = async (event) => {
  if (event.httpMethod !== 'POST') return json(405, { error: 'Method not allowed.' });

  const { data, error } = readBody(event, MAX_REQUEST_BYTES);
  if (error) return error;
  if (!data || typeof data !== 'object' || Array.isArray(data)) return json(400, { error: 'The request could not be read.' });

  const { fileBase64, fileName, ...fields } = data;
  if (Buffer.byteLength(JSON.stringify(fields), 'utf8') > MAX_FIELDS_BYTES) {
    return json(413, { error: 'The submission is too large.' });
  }

  const { value, errors } = validateSubmission(fields);
  if (errors) return json(400, { error: 'Please check the highlighted fields.', fields: errors });

  let fileBuffer = null;
  if (value.route === 'upload') {
    if (typeof fileBase64 !== 'string' || !fileBase64) return json(400, { error: 'The file is missing.', fields: { file: 'Choose the filled workbook.' } });
    fileBuffer = Buffer.from(fileBase64, 'base64');
    if (fileBuffer.length > MAX_FILE_BYTES) return json(413, { error: 'This file is larger than 4 MB.' });
    try {
      await readWorkbook(fileBuffer, fileName); // the stored file must be the readable workbook
    } catch (e) {
      return json(e instanceof ReadError ? e.status : 400, { error: e.message || 'We could not read this file.' });
    }
  } else if (fileBase64) {
    return json(400, { error: 'Only the upload route takes a file.' });
  }

  const url = supabaseUrl();
  const key = process.env.SUPABASE_SERVICE_ROLE_KEY;
  if (!url || !key) {
    console.error('submit: Supabase environment variables are missing');
    return json(500, { error: SAVE_ERROR });
  }
  const db = createClient(url, key, { auth: { persistSession: false, autoRefreshToken: false } });

  const id = crypto.randomUUID();
  let filePath = null;
  if (fileBuffer) {
    filePath = id + '/' + safeFileName(fileName);
    const up = await db.storage.from('submission-files').upload(filePath, fileBuffer, { contentType: XLSX_TYPE, upsert: false });
    if (up.error) {
      console.error('submit: file upload failed', up.error.message);
      return json(500, { error: SAVE_ERROR });
    }
  }

  const { data: rows, error: rpcError } = await db.rpc('create_submission', {
    payload: { ...value, id, file_path: filePath },
  });
  if (rpcError || !rows || !rows.length) {
    console.error('submit: create_submission failed', rpcError && rpcError.message);
    // remove the file this request just stored, so nothing is left without its submission
    if (filePath) await db.storage.from('submission-files').remove([filePath]);
    return json(500, { error: SAVE_ERROR });
  }

  return json(200, {
    reference: id.slice(0, 8).toUpperCase(),
    date: displayDate(rows[0].submitted_at),
    company_name: value.company_name,
  });
};
