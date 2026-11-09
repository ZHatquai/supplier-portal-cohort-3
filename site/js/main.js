(function () {
  'use strict';

  var btnYes = document.getElementById('btn-yes');
  var btnNo = document.getElementById('btn-no');
  var pathA = document.getElementById('path-a');
  var pathB = document.getElementById('path-b');
  var titleA = document.getElementById('path-a-title');
  var titleB = document.getElementById('path-b-title');

  // The choice lives in memory for the visit only. Nothing is stored; a reload resets it.
  function show(choice, moveFocus) {
    var isYes = choice === 'yes';
    pathA.hidden = !isYes;
    pathB.hidden = isYes;
    btnYes.setAttribute('aria-pressed', String(isYes));
    btnNo.setAttribute('aria-pressed', String(!isYes));
    btnYes.setAttribute('aria-expanded', String(isYes));
    btnNo.setAttribute('aria-expanded', String(!isYes));
    if (moveFocus) {
      (isYes ? titleA : titleB).focus({ preventScroll: false });
    }
  }

  btnYes.addEventListener('click', function () { show('yes', true); });
  btnNo.addEventListener('click', function () { show('no', true); });

  Array.prototype.forEach.call(document.querySelectorAll('[data-switch]'), function (link) {
    link.addEventListener('click', function (event) {
      event.preventDefault();
      show(link.getAttribute('data-switch'), true);
    });
  });
})();
