// ==UserScript==
// @name        Remove inoreader ADS
// @description Remove inoreader.com's advertisement in reading list, and upgrade button.
// @version     1
// @grant       none
// @include     https://www.inoreader.com/feed*
// @include     https://www.inoreader.com/all_articles*
// @namespace   https://raw.githubusercontent.com/Hacksign/configs/master/firefox/plugins/greasemonkey/inoreader.js
// @downloadURL https://raw.githubusercontent.com/Hacksign/configs/master/firefox/plugins/greasemonkey/inoreader.js
// @updateURL   https://raw.githubusercontent.com/Hacksign/configs/master/firefox/plugins/greasemonkey/inoreader.js
// ==/UserScript==
tools_div = document.getElementById('sb_rp_tools');
if (tools_div) {
  tools_div.style.right = '90px';
}
notifications_div = document.getElementById('sb_rp_notifications');
if (notifications_div) {
  notifications_div.style.right = '50px';
}
gear_div = document.getElementById('sb_rp_gear');
if (gear_div) {
  gear_div.style.right = '10px';
}
upgrade_div = document.getElementById('sb_rp_upgrade');
if (upgrade_div) {
  document.getElementById('sb_rp_upgrade').style.display = 'none';
}
reader_pane_div = document.getElementById('reader_pane');
if (reader_pane_div) {
  reader_pane_div.addEventListener('DOMNodeInserted', function (e) {
    if (e.originalTarget.id && e.originalTarget.id.indexOf('leaderboard_ad-') != - 1) {
      e.originalTarget.parentNode.removeChild(e.originalTarget);
    }
  }, false);
}
