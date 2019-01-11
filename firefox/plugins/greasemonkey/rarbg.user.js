// ==UserScript==
// @name         Hijack RARBG PopUps
// @namespace    https://github.com/Hacksign/configs/blob/master/firefox/plugins/greasemonkey/rarbg.user.js
// @version      0.1
// @description  Prevent rarbg from popping up annoying ad pages
// @author       Hacksign
// @match        https://rarbg.to/*
// @include      https://proxyrarbg.org/*
// @run-at      document-start
// ==/UserScript==

(function() {
    window.addEventListener(
        'beforescriptexecute',
        function(e) {
            if(e.target.src.match(/\/expla\d+\.js$/)){
                e.preventDefault();
                e.stopPropagation();
                window.removeEventListener(e.type, arguments.callee, true);
            }
        },
        true
    );
})();
