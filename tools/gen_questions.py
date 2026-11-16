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
data = {'sheet': 'Supplier Assessment 2026', 'sections': sections, 'questions': questions,
        'declaration': ws['A43'].value, 'templateNotes': {'S3-2': ws['F19'].value}}
js = ("/* Question list for the Supplier Sustainability Portal.\n"
      " * Generated from reference/The_Corporate_Supplier_Questionnaire_2026_39.xlsx (sheet, row, column D text,\n"
      " * type, ESRS reference and the workbook's own dropdown options). Do not reword; regenerate if the workbook changes.\n"
      " * Used by the page (window.TC_QUESTIONS) and bundled into the Netlify functions (module.exports). */\n"
      "(function (root) {\n  var data = " + json.dumps(data, ensure_ascii=False, indent=2).replace('\n', '\n  ') + ";\n"
      "  if (typeof module !== 'undefined' && module.exports) { module.exports = data; } else { root.TC_QUESTIONS = data; }\n"
      "})(typeof window !== 'undefined' ? window : this);\n")
open(out, 'w', encoding='utf-8').write(js)
print(len(questions), [q['id'] for q in questions])
print({q['id']: q.get('options') for q in questions if q['type']=='Dropdown'})
