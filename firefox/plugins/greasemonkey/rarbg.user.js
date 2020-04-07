// ==UserScript==
// @name         Hijack RARBG PopUps
// @namespace    https://github.com/Hacksign/configs/blob/master/firefox/plugins/greasemonkey/rarbg.user.js
// @version      0.1
// @description  Prevent rarbg from popping up annoying ad pages
// @author       Hacksign
// @match        https://rarbg.to/*
// @include      https://rarbgprx.org/*
// @include      https://proxyrarbg.org/*
// @include      https://rarbgunblocked.org/*
// @include      https://rarbgaccess.org/*
// @include      https://rarbgaccessed.org/*
// @include      https://rarbgcore.org/*
// @include      https://rarbgdata.org/*
// @include      https://rarbgenter.org/*
// @include      https://rarbgget.org/*
// @include      https://rarbggo.org/*
// @include      https://rarbgindex.org/*
// @include      https://rarbgmirror.org/*
// @include      https://rarbgmirrored.org/*
// @include      https://rarbgp2p.org/*
// @include      https://rarbgproxied.org/*
// @include      https://rarbgproxies.org/*
// @include      https://rarbgproxy.org/*
// @include      https://rarbgto.org/*
// @include      https://rarbgtor.org/*
// @include      https://rarbgtorrents.org/*
// @include      https://rarbgunblock.org/*
// @include      https://rarbgway.org/*
// @include      https://rarbgweb.org/*
// @include      https://unblockedrarbg.org/*
// @include      https://rarbg2018.org/*
// @include      https://rarbg2019.org/*
// @include      https://rarbg2020.org/*
// @include      https://rarbg2021.org/*
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
