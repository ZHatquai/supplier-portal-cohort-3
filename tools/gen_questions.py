import openpyxl, json, sys
wb_path = sys.argv[1]; out = sys.argv[2]
ws = openpyxl.load_workbook(wb_path)['Supplier Assessment 2026']
opts = {}
for dv in ws.data_validations.dataValidation:
    if dv.type == 'list' and dv.formula1:
        for rng in str(dv.sqref).split():
            for row in ws[rng] if ':' in rng else [[ws[rng]]]:
                for c in row:
                    if c.column_letter == 'E':
                        opts[c.row] = dv.formula1.strip('"').split(',')
sections = []; questions = []; cur = None; counter = {}
for r in range(5, 42):
    a, b, t, d, g = (ws.cell(r, c).value for c in (1, 2, 3, 4, 7))
    if t is None and d:
        cur = {'id': a, 'title': d, 'esrs': g}; sections.append(cur); continue
    if not t: continue
    counter[a] = counter.get(a, 0) + 1
    qid = f"{a}-{counter[a]}"
    q = {'id': qid, 'row': r, 'section': a, 'esrs': None if b in ('—', None) else b,
         'type': t, 'text': d, 'required': t == 'Required'}
    if t == 'Dropdown': q['options'] = opts.get(r, [])
    questions.append(q)
assert len(questions) == 30, len(questions)
# v2.1 number rule (spec Sections 5 and 9): the seven Quantitative questions, their unit,
# the evidence-note label where the question asks for more than the number, and a maximum where one applies.
NUMBERS = {
    'S2-1': {'unit': 'tCO2e', 'note_label': 'Verification method and notes'},
    'S2-2': {'unit': 'tCO2e'},
    'S2-3': {'unit': 'tCO2e', 'note_label': 'Categories included and notes'},
    'S3-1': {'unit': 'kg'},
    'S4-1': {'unit': 'm3', 'note_label': 'Source and notes'},
    'S5-1': {'unit': 'tonnes', 'note_label': 'Breakdown and notes'},
    'S5-2': {'unit': '%', 'max': 100},
}
assert sorted(NUMBERS) == sorted(q['id'] for q in questions if q['type'] == 'Quantitative')
for q in questions:
    if q['id'] in NUMBERS:
        q['number'] = NUMBERS[q['id']]
data = {'sheet': 'Supplier Assessment 2026', 'sections': sections, 'questions': questions,
        'declaration': ws['A43'].value}
NUMBER_JS = r'''
  // The number rule (spec v2.1, Section 9), one definition for the page and the submit function.
  // Accepts digits with an optional decimal point; a comma only as a thousands separator in groups of three.
  // Returns { ok: true, value } with the separators removed ('' when empty), or { ok: false, message }.
  data.NUMBER_MESSAGE = 'Enter a number only, for example 12345 or 12,345.6. Put any other detail in the notes.';
  data.PERCENT_MESSAGE = 'Enter a percentage from 0 to 100.';
  data.parseNumber = function (raw, rule) {
    var s = String(raw == null ? '' : raw).trim();
    if (s === '') return { ok: true, value: '' };
    var max = rule && typeof rule.max === 'number' ? rule.max : null;
    var message = max === null ? data.NUMBER_MESSAGE : data.PERCENT_MESSAGE;
    if (!/^(\d{1,3}(,\d{3})+|\d+)(\.\d+)?$/.test(s)) return { ok: false, message: message };
    var value = s.replace(/,/g, '');
    if (max !== null && Number(value) > max) return { ok: false, message: message };
    return { ok: true, value: value };
  };
'''
js = ("/* Question list for the Supplier Sustainability Portal.\n"
      " * Generated from reference/The_Corporate_Supplier_Questionnaire_2026_39.xlsx (sheet, row, column D text,\n"
      " * type, ESRS reference and the workbook's own dropdown options). Do not reword; regenerate if the workbook changes.\n"
      " * Used by the page (window.TC_QUESTIONS) and bundled into the Netlify functions (module.exports). */\n"
      "(function (root) {\n  var data = " + json.dumps(data, ensure_ascii=False, indent=2).replace('\n', '\n  ') + ";\n"
      + NUMBER_JS +
      "  if (typeof module !== 'undefined' && module.exports) { module.exports = data; } else { root.TC_QUESTIONS = data; }\n"
      "})(typeof window !== 'undefined' ? window : this);\n")
open(out, 'w', encoding='utf-8').write(js)
print(len(questions), [q['id'] for q in questions])
print({q['id']: q.get('options') for q in questions if q['type']=='Dropdown'})
