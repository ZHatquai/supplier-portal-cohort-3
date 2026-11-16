// Reads the filled questionnaire workbook. Used by parse-workbook (to show the answers for review)
// and by submit (to re-check the file before it is stored). Stores nothing, executes nothing.
'use strict';

const ExcelJS = require('exceljs');
const Q = require('../../site/js/questions.js');

const MAX_FILE_BYTES = 4 * 1024 * 1024;
const READ_ERROR = 'We could not read this file. Please use the questionnaire downloaded from this page, or fill in the form instead.';
const SIZE_ERROR = 'This file is larger than 4 MB. Please use the questionnaire downloaded from this page, or fill in the form instead.';

class ReadError extends Error {
  constructor(message, status) {
    super(message);
    this.status = status || 400;
  }
}

function norm(value) {
  return String(value == null ? '' : value).replace(/\s+/g, ' ').trim();
}

// Plain text of a cell, whatever ExcelJS hands back (rich text, hyperlink, formula result, date, number).
function cellText(cell) {
  const v = cell.value;
  if (v == null) return '';
  if (v instanceof Date) return v.toISOString().slice(0, 10);
  if (typeof v !== 'object') return String(v).trim();
  if (Array.isArray(v.richText)) return v.richText.map((p) => p.text).join('').trim();
  if (typeof v.text === 'string') return v.text.trim();
  if ('result' in v) return v.result == null ? '' : String(v.result).trim();
  return '';
}

function checkFile(buffer, fileName) {
  if (typeof fileName !== 'string' || !/\.xlsx$/i.test(fileName.trim())) throw new ReadError(READ_ERROR);
  if (!buffer || buffer.length === 0) throw new ReadError(READ_ERROR);
  if (buffer.length > MAX_FILE_BYTES) throw new ReadError(SIZE_ERROR, 413);
  // .xlsx is a zip archive: it starts with "PK"
  if (buffer[0] !== 0x50 || buffer[1] !== 0x4b) throw new ReadError(READ_ERROR);
}

async function readWorkbook(buffer, fileName) {
  checkFile(buffer, fileName);
  const wb = new ExcelJS.Workbook();
  try {
    await wb.xlsx.load(buffer);
  } catch (e) {
    throw new ReadError(READ_ERROR);
  }
  const ws = wb.getWorksheet(Q.sheet);
  if (!ws) throw new ReadError(READ_ERROR);

  for (const q of Q.questions) {
    if (norm(cellText(ws.getCell(q.row, 4))) !== norm(q.text)) throw new ReadError(READ_ERROR);
  }

  const answers = Q.questions.map((q) => {
    let note = cellText(ws.getCell(q.row, 6));
    const template = Q.templateNotes && Q.templateNotes[q.id];
    if (template && norm(note) === norm(template)) note = '';
    return { question_id: q.id, response: cellText(ws.getCell(q.row, 5)), evidence_note: note };
  });

  return { answers };
}

module.exports = { readWorkbook, ReadError, READ_ERROR, SIZE_ERROR, MAX_FILE_BYTES, Q };
