// ==UserScript==
// @name Remove inoreader ADS
// @description Remove inoreader.com's advertisement in reading list, upgrae button and some annoying dialogs.
// @version 4.7.1
// @grant none
// @include https://www.inoreader.com/*
// @include http://www.inoreader.com/*
// @include https://jp.inoreader.com/*
// @include http://jp.inoreader.com/*
// @namespace   https://raw.githubusercontent.com/Hacksign/configs/master/firefox/plugins/greasemonkey/inoreader.user.js
// ==/UserScript==
var tools_div = document.getElementById('sb_rp_tools');
if (tools_div) {
    tools_div.style.right = '90px';
}
var notifications_div = document.getElementById('sb_rp_notifications');
if (notifications_div) {
    notifications_div.style.right = '50px';
}
var gear_div = document.getElementById('sb_rp_gear');
if (gear_div) {
    gear_div.style.right = '10px';
}
var upgrade_div = document.getElementById('sb_rp_upgrade');
if (upgrade_div) {
    document.getElementById('sb_rp_upgrade').style.display = 'none';
}
var reader_pane_div = document.getElementById('reader_pane');
if (reader_pane_div) {
    reader_pane_div.addEventListener('DOMNodeInserted', function (e) {
        var relatedObj = e.originalTarget || e.target;
        if(relatedObj.parentNode) {
            if (relatedObj.id && relatedObj.id.indexOf('leaderboard_ad-') != - 1) {
                relatedObj.parentNode.removeChild(relatedObj);
            } else if (relatedObj.classList && relatedObj.classList.contains('ad_title')) {
                relatedObj.parentNode.removeChild(relatedObj);
            } else if (relatedObj.classList && relatedObj.classList.contains('dashboard_gadgets')) {
                //find and remove ads div in dashboard page
                var sub_divs = relatedObj.getElementsByTagName('div');
                for (var i = 0; i < sub_divs.length; ++i) {
                    if (sub_divs[i].classList && sub_divs[i].classList.contains('header_control')) {
                        if (!sub_divs[i].innerHTML.trim()) {
                            relatedObj.parentNode.removeChild(relatedObj);
                        }
                    }
                }
            }
        }
    }, false);
}
var sinner_div = document.getElementById('sinner_container');
if(sinner_div) {
    sinner_div.addEventListener('DOMNodeInserted', function(e) {
        var relatedObj = e.originalTarget || e.target;
        if(relatedObj.style){
            sinner_div.style.display = 'none';
            if(reader_pane_div) {
                reader_pane_div.style.paddingRight = '0px';
            }
        }
    });
}
var content_div = document.getElementById('three_way_contents');
if (content_div) {
    content_div.addEventListener('scroll', function () {
        if (content_div.scrollTop !== 0 && !document.getElementById('_gm_hacksign_topbar_content')) {
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
                    y = y - y / 5;
                    if (y < 50) {
                        y = 0;
                        content_div.scrollTop = 0;
                        clearInterval(timer);
                    }else content_div.scrollTop -= y;
                }, '25');
            };
            content_div.appendChild(topbar);
        } else if (content_div.scrollTop === 0 && document.getElementById('_gm_hacksign_topbar_content')) {
            content_div.removeChild(document.getElementById('_gm_hacksign_topbar_content'));
        }
    });
    content_div.addEventListener('DOMNodeInserted', function (e) {
        var relatedObj = e.originalTarget || e.target;
        if (relatedObj.id && relatedObj.id.indexOf('taboola_ad-') != - 1) {
            relatedObj.parentNode.removeChild(relatedObj);
        }
        if (relatedObj.id && relatedObj.id.indexOf('no_article_selected') != -1){
            relatedObj.addEventListener('DOMNodeInserted', function(f){
                var relatedObj2 = f.originalTarget || f.target;
                if(relatedObj2){
                    if(relatedObj2.getElementsByClassName && relatedObj2.getElementsByClassName('ad_title').length !== 0){
                        relatedObj2.getElementsByClassName('ad_title')[0].parentNode.removeChild(relatedObj2.getElementsByClassName('ad_title')[0]);
                    }
                    if(relatedObj2.getElementsByClassName && relatedObj2.getElementsByClassName('sinner_inner').length !== 0){
                        if(relatedObj2.getElementsByClassName('sinner_inner')[0]){
                            var div_sinn_inner = relatedObj2.getElementsByClassName('sinner_inner');
                            for(var i = 0; i < relatedObj2.getElementsByClassName('sinner_inner')[0].childNodes.length; ++i){
                                if(relatedObj2.getElementsByClassName('sinner_inner')[0].childNodes[i].id.indexOf('column_ad-') != -1){
                                    relatedObj2.getElementsByClassName('sinner_inner')[0].childNodes[i].style.display = 'none';
                                }
                            }
                        }
                    }
                    if(relatedObj2.getElementsByClassName && relatedObj2.getElementsByClassName('ad_footer_remove').length !== 0){
                        relatedObj2.getElementsByClassName('ad_footer_remove')[0].parentNode.removeChild(relatedObj2.getElementsByClassName('ad_footer_remove')[0]);
                    }
                }
            });
        }
        if (relatedObj.id && relatedObj.id.indexOf('article_full_contents') != - 1) {
            relatedObj.addEventListener('DOMNodeInserted', function (f) {
                var relatedObj2 = f.originalTarget || f.target;
                if(relatedObj2){
                    if (relatedObj2.classList && relatedObj2.classList.contains('ad_title')) {
                        relatedObj2.parentNode.removeChild(relatedObj2);
                    }
                    if (relatedObj2.attributes && relatedObj2.attributes.length === 0 && relatedObj2.childNodes.length !== 0) {
                        for (var i = 0; i < relatedObj2.childNodes.length; ++i) {
                            if (relatedObj2.childNodes[i].id.indexOf('inner_ad-') != - 1) {
                                relatedObj2.childNodes[i].style.display = 'none';
                            }
                        }
                    }
                    if (relatedObj2.classList && relatedObj2.classList.contains('ad_footer_remove')) {
                        relatedObj2.parentNode.removeChild(relatedObj2);
                    }
                    if (relatedObj2.classList && relatedObj2.classList.contains('sinner_under_footer')) {
                        relatedObj2.parentNode.removeChild(relatedObj2);
                        relatedObj.style.paddingBottom = '20px';
                    }
                }
            }, false);
        }
    }, false);
}

var overlay_div_id = undefined;
document.addEventListener('DOMNodeInserted', function(e) {
    var relatedObj = e.originalTarget || e.target;
    if(relatedObj.id && relatedObj.id.indexOf('_wrap') != -1) {
        var img_collections = relatedObj.getElementsByTagName('img');
        if(img_collections.length !=0 && img_collections.item(0) && img_collections.item(0).src.indexOf('adb_detected.png') != -1) {
            overlay_div_id = relatedObj.id.split('_')[0] + '_modal_overlay';
            relatedObj.parentNode.removeChild(relatedObj);
        }
        if(!relatedObj.style.zIndex) {
            relatedObj.style.zIndex = 1002;
        }
    }else if(overlay_div_id){
        if(relatedObj.id && relatedObj.id == overlay_div_id) {
            relatedObj.parentNode.removeChild(relatedObj);
            overlay_div_id = undefined;
        }
    }
})

