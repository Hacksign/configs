-- arch, awesome3 theme

--{{{ Main
local awful = require("awful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
awful.util = require("awful.util")

theme = {}

home          = os.getenv("HOME")
config        = awful.util.getdir("config")
shared        = "/usr/share/awesome"
if not awful.util.file_readable(shared .. "/icons/awesome16.png") then
    shared    = "/usr/share/local/awesome"
end
sharedicons   = shared .. "/icons"
sharedthemes  = shared .. "/themes"
themes        = config .. "/themes"
themename     = "/arch"
if not awful.util.file_readable(themes .. themename .. "/theme.lua") then
       themes = sharedthemes
end
themedir      = themes .. themename

theme.wallpaper    = home .. "/.wallpaper"
theme.icon_theme = "ultra-flat-icons"

--}}}

-- default font size is 10
theme.font          = "YaHei Consolas Hybrid" .. " " .. dpi(12)

theme.margin_horizontal        = dpi(35)
theme.margin_vertical        = dpi(150)
theme.border_width  = dpi(4)
theme.border_width_thin  = dpi(2)

theme.bg_normal     = "#000000"
theme.bg_focus      = "#1793d1"
theme.bg_urgent     = "#ff0000"
theme.bg_minimize   = "#000000"
theme.bg_systray   = "#000000"

theme.fg_normal     = "#1793d1"
theme.fg_focus      = "#000000"
theme.fg_urgent     = "#ffffff"
theme.fg_minimize   = "#1793d1"

theme.border_normal = "#cccccc"
theme.border_focus  = "#0e0e47"
theme.border_marked = "#ce0f35"

-- There are other variable sets
-- overriding the default one when
-- defined, the sets are:
-- [taglist|tasklist]_[bg|fg]_[focus|urgent]
-- titlebar_[bg|fg]_[normal|focus]
-- tooltip_[font|opacity|fg_color|bg_color|border_width|border_color]
-- mouse_finder_[color|timeout|animate_timeout|radius|factor]
-- Example:
--theme.taglist_bg_focus = "#ff0000"

-- Display the taglist squares
theme.taglist_squares_sel   = sharedthemes .. "/default/taglist/squarefw.png"
theme.taglist_squares_unsel = sharedthemes .. "/default/taglist/squarew.png"

theme.tasklist_floating_icon = sharedthemes .. "/default/tasklist/floatingw.png"

-- Variables set for theming the menu:
-- menu_[bg|fg]_[normal|focus]
-- menu_[border_color|border_width]
theme.menu_submenu_icon = sharedthemes .. "/default/submenu.png"
theme.menu_height = dpi(30)
theme.menu_width  = dpi(220)

-- You can add as many variables as
-- you wish and access them by using
-- beautiful.variable in your rc.lua
--theme.bg_widget = "#cc0000"

-- Define the image to load
theme.titlebar_close_button_normal = sharedthemes .. "/default/titlebar/close_normal.png"
theme.titlebar_close_button_focus  = sharedthemes .. "/default/titlebar/close_focus.png"

theme.titlebar_ontop_button_normal_inactive = sharedthemes .. "/default/titlebar/ontop_normal_inactive.png"
theme.titlebar_ontop_button_focus_inactive  = sharedthemes .. "/default/titlebar/ontop_focus_inactive.png"
theme.titlebar_ontop_button_normal_active = sharedthemes .. "/default/titlebar/ontop_normal_active.png"
theme.titlebar_ontop_button_focus_active  = sharedthemes .. "/default/titlebar/ontop_focus_active.png"

theme.titlebar_sticky_button_normal_inactive = sharedthemes .. "/default/titlebar/sticky_normal_inactive.png"
theme.titlebar_sticky_button_focus_inactive  = sharedthemes .. "/default/titlebar/sticky_focus_inactive.png"
theme.titlebar_sticky_button_normal_active = sharedthemes .. "/default/titlebar/sticky_normal_active.png"
theme.titlebar_sticky_button_focus_active  = sharedthemes .. "/default/titlebar/sticky_focus_active.png"

theme.titlebar_floating_button_normal_inactive = sharedthemes .. "/default/titlebar/floating_normal_inactive.png"
theme.titlebar_floating_button_focus_inactive  = sharedthemes .. "/default/titlebar/floating_focus_inactive.png"
theme.titlebar_floating_button_normal_active = sharedthemes .. "/default/titlebar/floating_normal_active.png"
theme.titlebar_floating_button_focus_active  = sharedthemes .. "/default/titlebar/floating_focus_active.png"

theme.titlebar_maximized_button_normal_inactive = sharedthemes .. "/default/titlebar/maximized_normal_inactive.png"
theme.titlebar_maximized_button_focus_inactive  = sharedthemes .. "/default/titlebar/maximized_focus_inactive.png"
theme.titlebar_maximized_button_normal_active = sharedthemes .. "/default/titlebar/maximized_normal_active.png"
theme.titlebar_maximized_button_focus_active  = sharedthemes .. "/default/titlebar/maximized_focus_active.png"

-- You can use your own layout icons like this:
theme.layout_fairh = sharedthemes .. "/default/layouts/fairhw.png"
theme.layout_fairv = sharedthemes .. "/default/layouts/fairvw.png"
theme.layout_floating  = sharedthemes .. "/default/layouts/floatingw.png"
theme.layout_magnifier = sharedthemes .. "/default/layouts/magnifierw.png"
theme.layout_max = sharedthemes .. "/default/layouts/maxw.png"
theme.layout_fullscreen = sharedthemes .. "/default/layouts/fullscreenw.png"
theme.layout_tilebottom = sharedthemes .. "/default/layouts/tilebottomw.png"
theme.layout_tileleft   = sharedthemes .. "/default/layouts/tileleftw.png"
theme.layout_tile = sharedthemes .. "/default/layouts/tilew.png"
theme.layout_tiletop = sharedthemes .. "/default/layouts/tiletopw.png"
theme.layout_spiral  = sharedthemes .. "/default/layouts/spiralw.png"
theme.layout_dwindle = sharedthemes .. "/default/layouts/dwindlew.png"

theme.awesome_icon = themedir .. "/awesome16.png"

return theme
