// ==UserScript==
// @name Remove inoreader ADS
// @description Remove inoreader.com's advertisement in reading list, and upgrade button.
// @version 3.3
// @grant none
// @include https://www.inoreader.com/*
// @include http://www.inoreader.com/*
// @namespace   https://raw.githubusercontent.com/Hacksign/configs/master/firefox/plugins/greasemonkey/inoreader.user.js
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
    } else if (e.originalTarget.classList && e.originalTarget.classList.contains('ad_title')) {
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
content_div = document.getElementById('three_way_contents');
if (content_div) {
  content_div.addEventListener('DOMNodeInserted', function (e) {
    if (e.originalTarget.id && e.originalTarget.id.indexOf('taboola_ad-') != - 1) {
      e.originalTarget.parentNode.removeChild(e.originalTarget);
    }
  }, false);
  content_div.addEventListener('scroll', function () {
    if (content_div.scrollTop != 0 && !document.getElementById('_gm_hacksign_topbar_content')) {
      var topbar = document.createElement('div');
      topbar.id = '_gm_hacksign_topbar_content';
      topbar.style.background = 'rgba(0, 0, 0, 0.3) none repeat scroll 0px 0px';
      topbar.style.position = 'fixed';
      topbar.style.textAlign = 'center';
      topbar.style.right = '20px';
      topbar.style.bottom = '10px';
      topbar.style.lineHeight = '30px';
      topbar.style.cursor = 'pointer';
      topbar.style.width = '40px';
      topbar.style.height = '40px';
      topbar.className='icon-arrow_up_big';
      topbar.onclick = function () {
        var y = content_div.scrollTop;
        var timer = setInterval(function () {
          y = y - y / 6;
          if (y < 50) {
            y = 0;
            content_div.scrollTo(0, y);
            clearInterval(timer);
          }
          content_div.scrollTo(0, y);
        }, '25');
      };
      content_div.appendChild(topbar);
    } else if (content_div.scrollTop == 0 && document.getElementById('_gm_hacksign_topbar_content')) {
      content_div.removeChild(document.getElementById('_gm_hacksign_topbar_content'));
    }
  });
  content_div.addEventListener('DOMNodeInserted', function (e) {
    if (e.originalTarget.id && e.originalTarget.id.indexOf('article_full_contents') != - 1) {
      e.originalTarget.addEventListener('DOMNodeInserted', function (f) {
        if (f.originalTarget.classList && f.originalTarget.classList.contains('ad_title')) {
          f.originalTarget.parentNode.removeChild(f.originalTarget);
        }
        if (f.originalTarget.attributes.length == 0 && f.originalTarget.childNodes.length != 0) {
          for (i = 0; i < f.originalTarget.childNodes.length; ++i) {
            if (f.originalTarget.childNodes[i].id.indexOf('inner_ad-') != - 1) {
              f.originalTarget.childNodes[i].style.display = 'none';
            }
          }
        }
        if (f.originalTarget.classList && f.originalTarget.classList.contains('ad_footer_remove')) {
          f.originalTarget.parentNode.removeChild(f.originalTarget);
        }
        if (f.originalTarget.classList && f.originalTarget.classList.contains('sinner_under_footer')) {
          f.originalTarget.parentNode.removeChild(f.originalTarget);
          e.originalTarget.style.paddingBottom = '20px';
        }
      }, false);
    }
  }, false);
}

