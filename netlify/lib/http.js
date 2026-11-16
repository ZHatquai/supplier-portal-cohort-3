'use strict';

function json(statusCode, body) {
  return {
    statusCode,
    headers: { 'Content-Type': 'application/json; charset=utf-8', 'Cache-Control': 'no-store' },
    body: JSON.stringify(body),
  };
}

// Raw request body as text; refuses anything over maxBytes before parsing.
function readBody(event, maxBytes) {
  if (!event.body) return { error: json(400, { error: 'The request was empty.' }) };
  const text = event.isBase64Encoded ? Buffer.from(event.body, 'base64').toString('utf8') : event.body;
  if (Buffer.byteLength(text, 'utf8') > maxBytes) {
    return { error: json(413, { error: 'The request is too large.' }) };
  }
  try {
    return { data: JSON.parse(text) };
  } catch (e) {
    return { error: json(400, { error: 'The request could not be read.' }) };
  }
}

module.exports = { json, readBody };
