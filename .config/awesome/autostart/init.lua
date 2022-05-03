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

local function shellexecute(process, cmd, with_shell, run_once)
    assert(type(process) == "string")
    local replacer = {
        ["+"]  = "%+",
        ["-"] = "%-",
        ["*"]  = "%*",
        ["?"]  = "%?" 
    }

    if run_once == nil or run_once == true then
        for p in processwalker() do
            if p:find(process:gsub("[-+?*]", replacer)) then
                return
            end
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
        call_now = true,
        autostart = false,
        single_shot = true,
        callback = function()
            shellexecute('xfce4-notifyd', '/usr/lib/xfce4/notifyd/xfce4-notifyd', true)
            shellexecute('fcitx5', 'fcitx5 -D 1>/dev/null 2>&1', true)
            --shellexecute('xfdesktop', 'xfdesktop --disable-debug --disable-wm-check', true)
            --shellexecute('pcmanfm', 'pcmanfm --desktop --one-screen', true)
            shellexecute('plank', os.getenv("HOME") .. '/.config/awesome/autostart/start-plank.sh', true, false)
            shellexecute('picom', 'picom')
            --shellexecute('syndaemon', 'syndaemon -t -k -i 2 -d 2>/dev/null')
            shellexecute('indicator-keylock', 'indicator-keylock')
            shellexecute('volumeicon', 'volumeicon')
            shellexecute('thunar', 'thunar --daemon')
            shellexecute('synology-note-station', 'bash -l -c "kdocker -d 30 -i /home/hacksign/.syno_ns_app/package.nw/icon/NoteStation_32.png /home/hacksign/.syno_ns_app/synology-note-station 1>/dev/null 2>&1"')
            shellexecute('nm-applet', 'nm-applet 1>/dev/null')
            shellexecute('goldendict', 'goldendict')
            --shellexecute('caffeine', 'caffeine')
            shellexecute('blueman-applet', 'bash -lc "/usr/bin/blueman-applet 1>/dev/null 2>&1"')
            shellexecute('/usr/bin/libinput-gestures', 'bash -c "/usr/bin/libinput-gestures-setup restart" 1>/dev/null 2>&1')
            shellexecute('remmina', 'remmina --icon')
            shellexecute('syncthing-gtk', 'syncthing-gtk --minimized')
        end
    }
)
