local os = require("os")
local lfs=require("lfs")
local gears=require("gears")
local awful=require("awful")
local type=type
local assert=assert
local coroutine=coroutine
local tonumber=tonumber
local io=io

-- {{{ Run programm once
local function processwalker()
   local function yieldprocess()
      for dir in lfs.dir("/proc") do
        -- All directories in /proc containing a number, represent a process
        if tonumber(dir) ~= nil then
          local f, err = io.open("/proc/"..dir.."/cmdline")
          if f then
            local cmdline = f:read("*all")
            f:close()
            if cmdline ~= "" then
              coroutine.yield(cmdline)
            end
          end
        end
      end
    end
    return coroutine.wrap(yieldprocess)
end

local function run_once(process, cmd, with_shell)
    assert(type(process) == "string")
    local replacer = {
        ["+"]  = "%+",
        ["-"] = "%-",
        ["*"]  = "%*",
        ["?"]  = "%?" 
    }

    for p in processwalker() do
        if p:find(process:gsub("[-+?*]", replacer)) then
            return
        end
    end
    if with_shell then
        return awful.spawn.with_shell(cmd or process)
    else
        return awful.spawn(cmd or process)
    end
end
-- }}}
--
gears.timer(
    {
        timeout = 0,
        autostart = true,
        single_shot = true,
        callback = function()
            run_once('xfce4-notifyd', '/usr/lib/xfce4/notifyd/xfce4-notifyd', true)
            --run_once('xfdesktop', 'xfdesktop --disable-debug --disable-wm-check', true)
            --run_once('pcmanfm', 'pcmanfm --desktop --one-screen', true)
            run_once('plank', os.getenv("HOME") .. '/.config/awesome/autostart/start-plank.sh', true)
            run_once('picom', 'picom')
            --run_once('syndaemon', 'syndaemon -t -k -i 2 -d 2>/dev/null')
            run_once('indicator-keylock', 'indicator-keylock')
            run_once('volumeicon', 'volumeicon')
            run_once('thunar', 'thunar --daemon')
            run_once('synology-note-station', 'bash -l -c "kdocker -d 30 -i /home/hacksign/.syno_ns_app/package.nw/icon/NoteStation_32.png /home/hacksign/.syno_ns_app/synology-note-station 1>/dev/null 2>&1"')
            run_once('nm-applet', 'nm-applet 1>/dev/null')
            run_once('fcitx5', 'fcitx5 1>/dev/null 2>&1')
            run_once('goldendict', 'goldendict')
            --run_once('caffeine', 'caffeine')
            run_once('blueman-applet', 'bash -lc "/usr/bin/blueman-applet 1>/dev/null 2>&1"')
            run_once('/usr/bin/libinput-gestures', 'bash -c "/usr/bin/libinput-gestures-setup restart" 1>/dev/null 2>&1')
            run_once('remmina', 'remmina --icon')
            run_once('syncthing-gtk', 'syncthing-gtk --minimized')
        end
    }
)
