/* Supplier Sustainability Portal: submission through the page (spec v2.1, section 04).
 * A Path short entry; B Path form or upload; review and confirm; confirmation.
 * Nothing is saved before the supplier confirms, and nothing is kept in the browser:
 * all state lives in memory for the visit and a reload clears it. An uploaded workbook
 * is only read to fill in the answers; the file is never sent with the submission. */
(function () {
  'use strict';

  var Q = window.TC_QUESTIONS;
  if (!Q) return;

  var MONTHS = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
  var MAX_FILE = 4 * 1024 * 1024;
  var MAX_TEXT = 4000;
  var READ_ERROR = 'We could not read this file. Please use the questionnaire downloaded from this page, or fill in the form instead.';
  var SIZE_ERROR = 'This file is larger than 4 MB. Please use the questionnaire downloaded from this page, or fill in the form instead.';
  var SAVE_ERROR = 'We could not save your submission. Nothing was recorded. Please try again.';
  var EMAIL = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  var S1_3_NO = ((Q.questions.filter(function (q) { return q.id === 'S1-3'; })[0] || {}).options || [])
    .filter(function (o) { return /^No/.test(o); })[0] || 'No';

  var state = { route: null, uploadAnswers: null };
  var NUMBER_QS = Q.questions.filter(function (q) { return q.number; });

  // A reload always returns to the neutral state: some browsers restore typed values, so clear them.
  function resetForms() { Array.prototype.forEach.call(document.querySelectorAll('form'), function (f) { f.reset(); }); }
  resetForms();
  window.addEventListener('pageshow', function (e) { if (e.persisted) window.location.reload(); });

  function $(id) { return document.getElementById(id); }

  function el(tag, attrs, children) {
    var node = document.createElement(tag);
    Object.keys(attrs || {}).forEach(function (k) {
      if (k === 'text') node.textContent = attrs[k];
      else if (k === 'className') node.className = attrs[k];
      else if (attrs[k] === true) node.setAttribute(k, '');
      else if (attrs[k] !== false && attrs[k] != null) node.setAttribute(k, attrs[k]);
    });
    (children || []).forEach(function (c) { if (c) node.appendChild(typeof c === 'string' ? document.createTextNode(c) : c); });
    return node;
  }

  function displayDate(d) { return d.getDate() + ' ' + MONTHS[d.getMonth()] + ' ' + d.getFullYear(); }
  function isoToday() {
    var d = new Date();
    return d.getFullYear() + '-' + String(d.getMonth() + 1).padStart(2, '0') + '-' + String(d.getDate()).padStart(2, '0');
  }
  function firstSentence(text) { return String(text).split('\n')[0].trim(); }
  function val(id) { var n = $(id); return n ? n.value.trim() : ''; }

  /* ---------- field errors ---------- */
  function setError(input, message) {
    var field = input.closest('.field') || input.parentNode;
    var id = input.id + '-err';
    var p = $(id);
    if (!p) {
      p = el('p', { className: 'field-error', id: id });
      field.appendChild(p);
    }
    p.textContent = '';
    p.appendChild(el('span', { className: 'err-label', text: 'Error' }));
    p.appendChild(document.createTextNode(' ' + message));
    input.setAttribute('aria-invalid', 'true');
    var described = (input.getAttribute('aria-describedby') || '').split(' ').filter(Boolean);
    if (described.indexOf(id) < 0) described.push(id);
    input.setAttribute('aria-describedby', described.join(' '));
  }
  function clearError(input) {
    var p = $(input.id + '-err');
    if (p) p.remove();
    input.removeAttribute('aria-invalid');
    var d = (input.getAttribute('aria-describedby') || '').split(' ').filter(function (x) { return x && x !== input.id + '-err'; });
    if (d.length) input.setAttribute('aria-describedby', d.join(' ')); else input.removeAttribute('aria-describedby');
  }
  // The number rule (questions.js parseNumber): marks or clears one number field, returns true when valid.
  function markNumber(input, rule) {
    var r = Q.parseNumber(input.value, rule);
    if (r.ok) clearError(input); else setError(input, r.message);
    return r.ok;
  }
  function clearErrors(scope) {
    Array.prototype.forEach.call(scope.querySelectorAll('.field-error'), function (p) { p.remove(); });
    Array.prototype.forEach.call(scope.querySelectorAll('[aria-invalid]'), function (n) {
      n.removeAttribute('aria-invalid');
      var d = (n.getAttribute('aria-describedby') || '').split(' ').filter(function (x) { return x && !/-err$/.test(x); });
      if (d.length) n.setAttribute('aria-describedby', d.join(' ')); else n.removeAttribute('aria-describedby');
    });
  }
  // checks: [{ id, label, required, email, url }]; returns the first invalid input or null
  function check(scope, checks) {
    clearErrors(scope);
    var first = null;
    checks.forEach(function (c) {
      var input = $(c.id);
      if (!input) return;
      var v = input.type === 'checkbox' ? input.checked : input.value.trim();
      var msg = null;
      if (c.required && !v) msg = c.message || ('Enter ' + c.label + '.');
      else if (c.email && v && !EMAIL.test(v)) msg = 'Enter a valid email address.';
      else if (c.url && v && !/^https?:\/\/\S+$/i.test(v)) msg = 'Enter a link that starts with https://';
      else if (c.number && v && !Q.parseNumber(v, c.number).ok) msg = Q.parseNumber(v, c.number).message;
      else if (typeof v === 'string' && v.length > MAX_TEXT) msg = 'This answer is too long. The limit is 4,000 characters.';
      if (msg) { setError(input, msg); if (!first) first = input; }
    });
    return first;
  }

  function showStatus(box, message, retry) {
    box.textContent = '';
    box.appendChild(el('p', {}, [el('span', { className: 'err-label', text: 'Error' }), ' ' + message]));
    if (retry) {
      var btn = el('button', { type: 'button', className: 'tc-btn-secondary', text: 'Try again' });
      btn.addEventListener('click', retry);
      box.appendChild(el('p', { className: 'actions' }, [btn]));
    }
    box.hidden = false;
  }

  function postJSON(url, body) {
    return fetch(url, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(body) })
      .then(function (r) {
        return r.json().catch(function () { return {}; }).then(function (data) { return { ok: r.ok, status: r.status, data: data }; });
      })
      .catch(function () { return { ok: false, status: 0, data: {} }; });
  }

  /* ---------- question fields ---------- */
  function questionField(prefix, q, values) {
    var v = values[q.id] || {};
    var rid = prefix + '-' + q.id + '-r';
    var nid = prefix + '-' + q.id + '-n';
    var label = el('label', { 'for': rid }, [
      el('span', { className: 'q-id', text: q.id + (q.esrs ? ' · ' + q.esrs : '') }),
      el('span', { className: 'q-text', text: q.text })
    ]);
    var control;
    if (q.type === 'Dropdown') {
      control = el('select', { className: 'tc-input', id: rid, name: rid }, [el('option', { value: '', text: 'Choose an answer' })]);
      (q.options || []).forEach(function (o) {
        var opt = el('option', { value: o, text: o });
        if (v.response === o) opt.selected = true;
        control.appendChild(opt);
      });
      if (v.response && (q.options || []).indexOf(v.response) < 0) {
        var other = el('option', { value: v.response, text: v.response });
        other.selected = true;
        control.appendChild(other);
      }
    } else if (q.type === 'Open-Ended') {
      control = el('textarea', { className: 'tc-input', id: rid, name: rid, rows: '5', maxlength: String(MAX_TEXT) });
      control.value = v.response || '';
    } else if (q.number) {
      // number only (spec v2.1): a text field with the decimal keypad, its unit beside it
      var uid = rid + '-unit';
      var input = el('input', { className: 'tc-input number-input', id: rid, name: rid, type: 'text', inputmode: 'decimal', autocomplete: false, maxlength: '40', 'aria-describedby': uid, 'data-number': q.id });
      input.value = v.response || '';
      input.addEventListener('change', function () { markNumber(input, q.number); });
      control = el('div', { className: 'unit-wrap' }, [input, el('span', { className: 'unit', id: uid, text: q.number.unit === '%' ? '%' : q.number.unit })]);
    } else {
      control = el('input', { className: 'tc-input', id: rid, name: rid, type: 'text', maxlength: String(MAX_TEXT) });
      control.value = v.response || '';
    }
    var note = el('textarea', { className: 'tc-input note-input', id: nid, name: nid, rows: '2', maxlength: String(MAX_TEXT) });
    note.value = v.evidence_note || '';
    var noteLabel = ((q.number && q.number.note_label) || 'Notes and evidence') + ' (optional)';
    return el('div', { className: 'question' }, [
      el('div', { className: 'field' }, [label, control]),
      el('div', { className: 'field' }, [el('label', { 'for': nid, className: 'note-label', text: noteLabel }), note])
    ]);
  }

  function fixedField(q, value) {
    return el('div', { className: 'question' }, [
      el('div', { className: 'field' }, [
        el('p', { className: 'fixed-label' }, [el('span', { className: 'q-id', text: q.id + (q.esrs ? ' · ' + q.esrs : '') }), el('span', { className: 'q-text', text: firstSentence(q.text) })]),
        el('p', { className: 'fixed-value', text: value || 'No answer' })
      ])
    ]);
  }

  function simpleInput(id, labelText, required, type, autocomplete, max) {
    return el('div', { className: 'field' }, [
      el('label', { 'for': id }, [labelText + ' ', el('span', { className: required ? 'req' : 'opt', text: required ? '(required)' : '(optional)' })]),
      el('input', { className: 'tc-input', id: id, name: id, type: type || 'text', autocomplete: autocomplete || false, maxlength: String(max || 200), required: !!required })
    ]);
  }

  function sectionGroup(s) {
    var legend = el('legend', {}, [el('span', { className: 'tc-label', text: s.id + (s.esrs ? ' · ' + s.esrs : '') }), el('span', { className: 'group-title', text: s.title })]);
    return el('fieldset', { className: 'group' }, [legend]);
  }

  // The on-page form: S1 as separate company and contact fields, then every question
  function renderForm() {
    var root = $('q-fields');
    Q.sections.forEach(function (s) {
      var g = sectionGroup(s);
      Q.questions.filter(function (q) { return q.section === s.id; }).forEach(function (q) {
        if (q.id === 'S1-1') {
          g.appendChild(simpleInput('q-company_name', 'Company legal name', true, 'text', 'organization', 300));
          g.appendChild(simpleInput('q-company_country', 'Registered country', true, 'text', 'country-name', 200));
        } else if (q.id === 'S1-2') {
          g.appendChild(simpleInput('q-contact_name', 'Primary contact name', true, 'text', 'name', 200));
          g.appendChild(simpleInput('q-contact_title', 'Primary contact title', false, 'text', 'organization-title', 200));
          g.appendChild(simpleInput('q-contact_email', 'Primary contact email', true, 'email', 'email', 320));
        } else if (q.id === 'S1-3') {
          g.appendChild(fixedField(q, S1_3_NO));
        } else {
          g.appendChild(questionField('q', q, {}));
        }
      });
      root.appendChild(g);
    });
  }

  function answersFrom(prefix, fixedS13) {
    return Q.questions.map(function (q) {
      if (q.id === 'S1-1' || q.id === 'S1-2') return { question_id: q.id, response: '', evidence_note: '' };
      if (q.id === 'S1-3') return { question_id: q.id, response: fixedS13, evidence_note: '' };
      return { question_id: q.id, response: val(prefix + '-' + q.id + '-r'), evidence_note: val(prefix + '-' + q.id + '-n') };
    });
  }

  /* ---------- panels ---------- */
  var panels = { form: 'panel-form', upload: 'panel-upload', review: 'panel-review', done: 'panel-done' };
  function showPanel(name) {
    Object.keys(panels).forEach(function (k) { $(panels[k]).hidden = k !== name; });
    $('b-start').hidden = name === 'review' || name === 'done';
    ['form', 'upload'].forEach(function (w) {
      var b = $('way-' + w);
      b.setAttribute('aria-pressed', String(name === w));
      b.setAttribute('aria-expanded', String(name === w));
    });
    var target = name === 'done' ? $('panel-done') : $(panels[name] + '-title');
    if (target) target.focus();
  }

  $('way-form').addEventListener('click', function () { showPanel('form'); });
  $('way-upload').addEventListener('click', function () { showPanel('upload'); });

  /* ---------- A Path: short entry ---------- */
  var aForm = $('a-form');
  function saveA(event) {
    if (event) event.preventDefault();
    $('a-error').hidden = true;
    var bad = check(aForm, [
      { id: 'a-company_name', label: 'company name', required: true },
      { id: 'a-contact_name', label: 'contact name', required: true },
      { id: 'a-contact_email', label: 'contact email', required: true, email: true },
      { id: 'a-ecovadis_link', label: 'EcoVadis scorecard link', url: true }
    ]);
    if (bad) { bad.focus(); return; }
    var btn = $('a-save');
    btn.disabled = true;
    btn.textContent = 'Saving';
    postJSON('/.netlify/functions/submit', {
      route: 'ecovadis',
      company_name: val('a-company_name'),
      contact_name: val('a-contact_name'),
      contact_email: val('a-contact_email'),
      ecovadis_link: val('a-ecovadis_link')
    }).then(function (res) {
      btn.disabled = false;
      btn.textContent = 'Save and continue';
      var go = $('a-go');
      go.hidden = false;
      if (res.ok) {
        // one next step: share the scorecard on EcoVadis, with Go to EcoVadis as the single action
        aForm.hidden = true;
        $('a-lead').hidden = true;
        var done = $('a-done');
        done.textContent = '';
        var heading = el('h4', { className: 'tc-h2 done-title', id: 'a-done-title', tabindex: '-1', text: 'One step left' });
        done.appendChild(heading);
        done.appendChild(el('p', { className: 'done-line', text: 'Share your scorecard with The Corporate on EcoVadis.' }));
        done.appendChild(go);
        done.appendChild(el('p', { className: 'done-small', text: 'Saved on ' + res.data.date + ' for ' + res.data.company_name + '. Reference ' + res.data.reference + '.' }));
        done.hidden = false;
        heading.focus();
      } else if (res.status === 400 && res.data.fields) {
        Object.keys(res.data.fields).forEach(function (f) { var n = $('a-' + f); if (n) setError(n, res.data.fields[f]); });
        var first = aForm.querySelector('[aria-invalid]');
        if (first) first.focus();
        go.hidden = true;
      } else {
        showStatus($('a-error'), SAVE_ERROR, saveA);
        $('a-error').parentNode.insertBefore(go, $('a-error').nextSibling);
        $('a-error').focus && $('a-error').setAttribute('tabindex', '-1');
        $('a-error').focus();
      }
    });
  }
  aForm.addEventListener('submit', saveA);

  /* ---------- B Path: form ---------- */
  renderForm();
  $('q-form').addEventListener('submit', function (event) {
    event.preventDefault();
    var checks = [
      { id: 'q-company_name', label: 'company name', required: true },
      { id: 'q-company_country', label: 'country', required: true },
      { id: 'q-contact_name', label: 'contact name', required: true },
      { id: 'q-contact_title', label: 'contact title' },
      { id: 'q-contact_email', label: 'contact email', required: true, email: true }
    ];
    Q.questions.forEach(function (q) {
      checks.push({ id: 'q-' + q.id + '-r', label: 'an answer', number: q.number || null });
      checks.push({ id: 'q-' + q.id + '-n', label: 'a note' });
    });
    var bad = check($('q-form'), checks);
    if (bad) { bad.focus(); return; }
    state.route = 'form';
    ['company_name', 'company_country', 'contact_name', 'contact_title', 'contact_email'].forEach(function (f) { $('r-' + f).value = val('q-' + f); });
    openReview();
  });

  /* ---------- B Path: upload ---------- */
  function splitHints(answers) {
    var byId = {};
    answers.forEach(function (a) { byId[a.question_id] = a.response || ''; });
    var s11 = byId['S1-1'], s12 = byId['S1-2'];
    var hint = {};
    if (s11) {
      var cut = s11.lastIndexOf(',');
      hint.company_name = (cut > 0 ? s11.slice(0, cut) : s11).trim();
      hint.company_country = cut > 0 ? s11.slice(cut + 1).trim() : '';
    }
    if (s12) {
      var parts = s12.split(/[,;\n]/).map(function (p) { return p.trim(); }).filter(Boolean);
      var email = parts.filter(function (p) { return EMAIL.test(p); })[0] || '';
      var rest = parts.filter(function (p) { return p !== email; });
      hint.contact_email = email;
      hint.contact_name = rest[0] || '';
      hint.contact_title = rest.slice(1).join(', ');
    }
    return { hint: hint, s11: s11, s12: s12, s13: byId['S1-3'] || '' };
  }

  $('u-form').addEventListener('submit', function (event) {
    event.preventDefault();
    var box = $('u-error');
    box.hidden = true;
    clearErrors($('u-form'));
    var input = $('u-file');
    var file = input.files && input.files[0];
    if (!file) { setError(input, 'Choose the filled workbook.'); input.focus(); return; }
    if (!/\.xlsx$/i.test(file.name)) { showStatus(box, READ_ERROR); return; }
    if (file.size > MAX_FILE) { showStatus(box, SIZE_ERROR); return; }
    var btn = $('u-read');
    btn.disabled = true;
    btn.textContent = 'Reading';
    var reader = new FileReader();
    reader.onerror = function () { btn.disabled = false; btn.textContent = 'Read the file'; showStatus(box, READ_ERROR); };
    reader.onload = function () {
      var b64 = String(reader.result).split(',')[1] || '';
      postJSON('/.netlify/functions/parse-workbook', { fileName: file.name, fileBase64: b64 }).then(function (res) {
        btn.disabled = false;
        btn.textContent = 'Read the file';
        if (!res.ok || !res.data.answers) { showStatus(box, res.data.error || READ_ERROR); return; }
        state.route = 'upload';
        state.uploadAnswers = res.data.answers;
        var h = splitHints(res.data.answers);
        ['company_name', 'company_country', 'contact_name', 'contact_title', 'contact_email'].forEach(function (f) { $('r-' + f).value = h.hint[f] || ''; });
        state.s1 = h;
        openReview();
      });
    };
    reader.readAsDataURL(file);
  });

  /* ---------- review and confirm ---------- */
  function renderReviewAnswers() {
    var root = $('r-answers');
    root.textContent = '';
    if (state.route === 'form') {
      Q.sections.forEach(function (s) {
        var g = sectionGroup(s);
        var dl = el('dl', { className: 'review-list' });
        Q.questions.filter(function (q) { return q.section === s.id && q.id !== 'S1-1' && q.id !== 'S1-2'; }).forEach(function (q) {
          var response = q.id === 'S1-3' ? S1_3_NO : val('q-' + q.id + '-r');
          var note = q.id === 'S1-3' ? '' : val('q-' + q.id + '-n');
          dl.appendChild(el('dt', {}, [el('span', { className: 'q-id', text: q.id }), el('span', { className: 'q-text', text: q.id === 'S1-3' ? firstSentence(q.text) : q.text })]));
          dl.appendChild(el('dd', { text: response ? response + (q.number ? ' ' + q.number.unit : '') : 'No answer' }));
          if (note) dl.appendChild(el('dd', { className: 'review-note', text: 'Notes and evidence: ' + note }));
        });
        g.appendChild(dl);
        root.appendChild(g);
      });
      $('r-edit-wrap').hidden = false;
    } else {
      var values = {};
      state.uploadAnswers.forEach(function (a) { values[a.question_id] = a; });
      var hints = state.s1 || {};
      Q.sections.forEach(function (s) {
        var g = sectionGroup(s);
        Q.questions.filter(function (q) { return q.section === s.id; }).forEach(function (q) {
          if (q.id === 'S1-1' || q.id === 'S1-2') {
            var raw = q.id === 'S1-1' ? hints.s11 : hints.s12;
            g.appendChild(fixedField(q, raw ? 'From your file: ' + raw + '. Confirm it in Company and contact above.' : 'Not in your file. Enter it in Company and contact above.'));
          } else if (q.id === 'S1-3') {
            g.appendChild(fixedField(q, hints.s13));
          } else {
            g.appendChild(questionField('r', q, values));
          }
        });
        root.appendChild(g);
      });
      // a number cell that holds text is marked for correction, not refused (spec v2.1)
      NUMBER_QS.forEach(function (q) { var n = $('r-' + q.id + '-r'); if (n && n.value.trim()) markNumber(n, q.number); });
      $('r-edit-wrap').hidden = true;
    }
  }
  function numbersValid() {
    if (state.route !== 'upload') return true;
    return NUMBER_QS.every(function (q) { var n = $('r-' + q.id + '-r'); return !n || Q.parseNumber(n.value, q.number).ok; });
  }

  function updateDateShown() {
    var v = $('r-declaration_date').value;
    var d = /^\d{4}-\d{2}-\d{2}$/.test(v) ? new Date(v + 'T00:00:00') : null;
    $('r-date-shown').textContent = d && !isNaN(d) ? displayDate(d) : '';
  }

  function reviewComplete() {
    return ['r-company_name', 'r-company_country', 'r-contact_name', 'r-declaration_name', 'r-declaration_date'].every(function (id) { return val(id); }) &&
      EMAIL.test(val('r-contact_email')) && $('r-declaration_confirmed').checked && numbersValid();
  }
  function updateConfirm() {
    $('r-confirm').disabled = saving || !reviewComplete();
    updateDateShown();
    // name the number answers still to correct, so a disabled button is never a puzzle
    var hint = $('r-number-hint');
    var bad = state.route !== 'upload' ? [] : NUMBER_QS.filter(function (q) {
      var n = $('r-' + q.id + '-r'); return n && !Q.parseNumber(n.value, q.number).ok;
    }).map(function (q) { return q.id; });
    hint.hidden = !bad.length;
    hint.textContent = bad.length ? 'Correct the marked number ' + (bad.length === 1 ? 'answer' : 'answers') + ' before you submit: ' + bad.join(', ') + '.' : '';
  }

  function openReview() {
    $('decl-text').textContent = Q.declaration;
    if (!$('r-declaration_date').value) $('r-declaration_date').value = isoToday();
    $('r-error').hidden = true;
    clearErrors($('r-form'));
    renderReviewAnswers();
    updateConfirm();
    showPanel('review');
  }

  $('r-form').addEventListener('input', function (e) {
    var t = e.target;
    var q = t && t.getAttribute && t.getAttribute('data-number');
    // clear a number field's mark as soon as it holds a valid number (marked again on change if not)
    if (q && Q.parseNumber(t.value, NUMBER_QS.filter(function (x) { return x.id === q; })[0].number).ok) clearError(t);
    updateConfirm();
  });
  $('r-form').addEventListener('change', updateConfirm);
  $('r-edit').addEventListener('click', function () {
    ['company_name', 'company_country', 'contact_name', 'contact_title', 'contact_email'].forEach(function (f) { $('q-' + f).value = val('r-' + f); });
    showPanel('form');
  });
  $('r-back').addEventListener('click', function () {
    if (state.route === 'form') $('r-edit').click(); else showPanel('upload');
  });

  var saving = false;
  function confirmSubmit(event) {
    if (event) event.preventDefault();
    if (saving) return;
    $('r-error').hidden = true;
    var checks = [
      { id: 'r-company_name', label: 'company name', required: true },
      { id: 'r-company_country', label: 'country', required: true },
      { id: 'r-contact_name', label: 'contact name', required: true },
      { id: 'r-contact_title', label: 'contact title' },
      { id: 'r-contact_email', label: 'contact email', required: true, email: true },
      { id: 'r-declaration_name', label: 'authorised signatory name', required: true },
      { id: 'r-declaration_date', label: 'declaration date', required: true },
      { id: 'r-declaration_confirmed', required: true, message: 'Confirm that the information is accurate and complete.' }
    ];
    if (state.route === 'upload') {
      Q.questions.forEach(function (q) {
        checks.push({ id: 'r-' + q.id + '-r', label: 'an answer', number: q.number || null });
        checks.push({ id: 'r-' + q.id + '-n', label: 'a note' });
      });
    }
    var bad = check($('r-form'), checks);
    if (bad) { bad.focus(); return; }

    var answers = state.route === 'form' ? answersFrom('q', S1_3_NO) : answersFrom('r', (state.s1 || {}).s13 || '');
    var body = {
      route: state.route,
      company_name: val('r-company_name'),
      company_country: val('r-company_country'),
      contact_name: val('r-contact_name'),
      contact_title: val('r-contact_title'),
      contact_email: val('r-contact_email'),
      ecovadis_link: state.route === 'form' ? val('q-S1-4-r') : '',
      declaration_name: val('r-declaration_name'),
      declaration_date: val('r-declaration_date'),
      declaration_confirmed: $('r-declaration_confirmed').checked,
      answers: answers
    };
    if (body.ecovadis_link && !/^https?:\/\//i.test(body.ecovadis_link)) body.ecovadis_link = '';

    saving = true;
    var btn = $('r-confirm');
    btn.disabled = true;
    btn.textContent = 'Saving';
    postJSON('/.netlify/functions/submit', body).then(function (res) {
      saving = false;
      btn.textContent = 'Confirm and submit';
      updateConfirm();
      if (res.ok) {
        var done = $('panel-done');
        done.textContent = '';
        done.appendChild(el('h4', { className: 'tc-h3', text: 'Submission received.' }));
        done.appendChild(el('p', { text: 'Received on ' + res.data.date + ' for ' + res.data.company_name + '.' }));
        done.appendChild(el('p', { text: 'Reference ' + res.data.reference + '.' }));
        done.appendChild(el('p', { text: 'Submitting again with the same company name and contact email replaces this submission.' }));
        showPanel('done');
      } else if (res.status === 400 && res.data.fields) {
        Object.keys(res.data.fields).forEach(function (f) {
          var m = /^answer_(S\d-\d)$/.exec(f);
          var n = m ? $((state.route === 'form' ? 'q-' : 'r-') + m[1] + '-r') : $('r-' + f);
          if (n) setError(n, res.data.fields[f]);
        });
        showStatus($('r-error'), res.data.error || 'Please check the highlighted fields.');
        var first = $('r-form').querySelector('[aria-invalid]');
        if (first) first.focus();
      } else {
        showStatus($('r-error'), res.status === 400 || res.status === 413 ? (res.data.error || SAVE_ERROR) : SAVE_ERROR, res.status === 400 ? null : confirmSubmit);
        $('r-error').setAttribute('tabindex', '-1');
        $('r-error').focus();
      }
    });
  }
  $('r-form').addEventListener('submit', confirmSubmit);
})();
