// ==UserScript==
// @name        Remove inoreader ADS
// @description Remove inoreader.com's advertisement in reading list, and upgrade button.
// @version     2
// @grant       none
// @include     https://www.inoreader.com/feed/*
// @include     https://www.inoreader.com/folder/*
// @include     https://www.inoreader.com/all_articles
// @include     https://www.inoreader.com/starred
// @include     https://www.inoreader.com/dashboard
// @include	https://www.inoreader.com/trending
// @include	https://www.inoreader.com/liked
// @include	https://www.inoreader.com/commented
// @include	https://www.inoreader.com/recent
// @include	https://www.inoreader.com/web_pages
// @include	https://www.inoreader.com/channel
// @include	https://www.inoreader.com/my_channel
// @namespace   https://raw.githubusercontent.com/Hacksign/configs/master/firefox/plugins/greasemonkey/inoreader.user.js
// @downloadURL https://raw.githubusercontent.com/Hacksign/configs/master/firefox/plugins/greasemonkey/inoreader.user.js
// @updateURL   https://raw.githubusercontent.com/Hacksign/configs/master/firefox/plugins/greasemonkey/inoreader.user.js
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
    } else if (e.originalTarget.classList && e.originalTarget.classList.contains('dashboard_gadgets')) {
      //find and remove ads div in dashboard page
      sub_divs = e.originalTarget.getElementsByTagName('div');
      for (i = 0; i < sub_divs.length; ++i) {
        if (sub_divs[i].classList && sub_divs[i].classList.contains('header_control')) {
          if (!sub_divs[i].innerHTML.trim()) {
            e.originalTarget.parentNode.removeChild(e.originalTarget);
          }
        }
      }
    }
  }, false);
}
