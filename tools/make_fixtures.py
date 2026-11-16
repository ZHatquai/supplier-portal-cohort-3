"""Builds the data-check fixtures in fixtures/ from a COPY of the reference workbook.
The reference file itself is never edited. Run: python3 -I tools/make_fixtures.py"""
import json, os, shutil, zipfile, random, openpyxl

REF = 'reference/The_Corporate_Supplier_Questionnaire_2026_39.xlsx'
OUT = 'fixtures'
SHEET = 'Supplier Assessment 2026'
os.makedirs(OUT, exist_ok=True)

ws0 = openpyxl.load_workbook(REF)[SHEET]
rows = [r for r in range(6, 42) if ws0.cell(r, 3).value]           # the 30 question rows
counter, ids = {}, []
for r in rows:
    s = ws0.cell(r, 1).value; counter[s] = counter.get(s, 0) + 1; ids.append((f"{s}-{counter[s]}", r, ws0.cell(r, 3).value))

# 1. filled workbook with 30 known answers
wb = openpyxl.load_workbook(REF); ws = wb[SHEET]
expected = []
for qid, r, typ in ids:
    resp = {'S1-1': 'Fixture Components GmbH, Germany',
            'S1-2': 'Alex Example, Sustainability Lead, alex@fixture.example',
            'S1-3': 'No — Will Complete Questionnaire'}.get(qid)
    if resp is None:
        resp = 'Yes' if typ == 'Dropdown' else f'Fixture response {qid}'
    note = '' if qid in ('S1-1', 'S1-2', 'S1-3') else f'Fixture note {qid}'
    ws.cell(r, 5).value = resp
    ws.cell(r, 6).value = note or ws.cell(r, 6).value   # S1 rows keep their (empty) notes
    expected.append({'question_id': qid, 'response': resp, 'evidence_note': note})
wb.save(f'{OUT}/workbook_filled.xlsx')
json.dump({'answers': expected}, open(f'{OUT}/workbook_filled.expected.json', 'w'), ensure_ascii=False, indent=1)

# 2. wrong layout: two question rows swapped
wb = openpyxl.load_workbook(REF); ws = wb[SHEET]
a, b = ws.cell(11, 4).value, ws.cell(12, 4).value
ws.cell(11, 4).value, ws.cell(12, 4).value = b, a
wb.save(f'{OUT}/workbook_wrong_layout.xlsx')

# 3. not a workbook
open(f'{OUT}/not_a_workbook.pdf', 'wb').write(b'%PDF-1.4\n1 0 obj << /Type /Catalog >> endobj\ntrailer << /Root 1 0 R >>\n%%EOF\n')

# 4. oversize: a valid copy of the workbook padded past 4 MB
shutil.copy(REF, f'{OUT}/workbook_oversize.xlsx')
random.seed(7)
with zipfile.ZipFile(f'{OUT}/workbook_oversize.xlsx', 'a', compression=zipfile.ZIP_STORED) as z:
    z.writestr('xl/media/padding.bin', random.randbytes(4 * 1024 * 1024 + 200_000))
for f in sorted(os.listdir(OUT)):
    print(f, os.path.getsize(f'{OUT}/{f}'))
