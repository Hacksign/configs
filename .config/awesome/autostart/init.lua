local require=require
local type=type
local assert=assert
local coroutine=coroutine
local tonumber=tonumber
local io=io local lfs=require("lfs") local awful=require("awful")
module("autostart")

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

local function run_once(process, cmd)
   assert(type(process) == "string")
   local regex_killer = {
      ["+"]  = "%+", ["-"] = "%-",
      ["*"]  = "%*", ["?"]  = "%?" }

   for p in processwalker() do
      if p:find(process:gsub("[-+?*]", regex_killer)) then
         return
      end
   end
   return awful.spawn(cmd or process)
end
-- }}}

run_once('compton', 'compton')
run_once('syndaemon', 'syndaemon -t -k -i 2 -d 2>/dev/null')
run_once('indicator-keylock', 'indicator-keylock')
run_once('volumeicon', 'volumeicon')
run_once('thunar', 'thunar --daemon')
run_once('nm-applet', 'nm-applet 1>/dev/null')
run_once('fcitx', 'fcitx -D -r 2>/dev/null')
run_once('goldendict', 'goldendict')
run_once('thunderbird', 'thunderbird')
run_once('ss-qt5', 'ss-qt5')
run_once('EvernoteTray', 'wine  "/home/hacksign/Software/Program Files (x86)/Evernote/Evernote/EvernoteTray.exe" 1>/dev/null 2>&1')
run_once('BaiduNetdisk.exe', 'wine "/home/hacksign/.wine/drive_c/users/hacksign/Application Data/baidu/BaiduNetdisk/BaiduNetdisk.exe" AutoRun')
run_once('caffeine', 'caffeine')
run_once('blueman-applet', 'blueman-applet 1>/dev/null 2>&1')
run_once('fusuma', '/home/hacksign/.gem/ruby/2.4.0/bin/fusuma 1>/dev/null 2>&1')
run_once('xfdesktop', 'xfdesktop --disable-wm-check')
