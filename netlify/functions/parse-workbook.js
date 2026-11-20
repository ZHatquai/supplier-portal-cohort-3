// parse-workbook: reads an uploaded questionnaire and returns its answers for the supplier to review.
// It touches no table and no storage, and keeps nothing (docs/access-matrix.md Section 1).
'use strict';

const { readWorkbook, ReadError, READ_ERROR } = require('../lib/workbook.js');
const { json, readBody } = require('../lib/http.js');

// a 4 MB file is about 5.6 MB once base64-encoded, plus the file name
const MAX_REQUEST_BYTES = 5.8 * 1024 * 1024;

exports.handler = async (event) => {
  if (event.httpMethod !== 'POST') return json(405, { error: 'Method not allowed.' });

  const { data, error } = readBody(event, MAX_REQUEST_BYTES);
  if (error) return error.statusCode === 413 ? json(413, { error: 'This file is larger than 4 MB. Please use the questionnaire downloaded from this page, or fill in the form instead.' }) : json(400, { error: READ_ERROR });
  if (!data || typeof data.fileBase64 !== 'string') return json(400, { error: READ_ERROR });

  try {
    const buffer = Buffer.from(data.fileBase64, 'base64');
    const result = await readWorkbook(buffer, data.fileName);
    return json(200, result);
  } catch (e) {
    if (e instanceof ReadError) return json(e.status, { error: e.message });
    return json(400, { error: READ_ERROR });
  }
};
