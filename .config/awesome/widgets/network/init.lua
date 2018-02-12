local require = require
local tonumber = tonumber
local naughty = require("naughty")
local io = require("io")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local math = require('math')
local wibox = require('wibox')
local awful = require("awful")
local beautiful = require("beautiful")

module("network")

function trim(s)
    return (s:gsub("^%s*(.-)%s*$", "%1"))
end

function get_device()
    f = io.popen("ip link show | cut -d' ' -f2,9")
    ws = f:read("*a")
    f:close()
    ws = ws:match("%w+: UP") or ws:match("ppp%w+: UNKNOWN")
    if ws ~= nil then
        return ws:match("(%w+):")
    else
        return "network off"
    end
end

local icon_widget = {
    send = wibox.container.margin(
        wibox.widget {
            image = '/usr/share/icons/ultra-flat-icons/actions/symbolic/go-up-symbolic.svg',
            resize = true,
            widget = wibox.widget.imagebox
        },
        dpi(12),
        dpi(-5),
        dpi(12),
        dpi(12),
        nil
    ),
    receive = wibox.container.margin(
        wibox.widget {
            image = '/usr/share/icons/ultra-flat-icons/actions/symbolic/go-down-symbolic.svg',
            resize = true,
            widget = wibox.widget.imagebox
        },
        dpi(12),
        dpi(-5),
        dpi(12),
        dpi(12),
        nil
    )
}

local network_widget = {
    last_sent = nil,
    last_receive = nil,
    time_interval = 5,
    send = wibox.widget {
        align = 'center',
        valign = 'center',
        widget =  wibox.widget.textbox,
    },
    receive = wibox.widget {
        align = 'center',
        valign = 'center',
        widget =  wibox.widget.textbox,
    }
} 

local network_layout = wibox.widget {
    icon_widget.send,
    network_widget.send,
    icon_widget.receive,
    network_widget.receive,
    forced_num_cols = 4,
    forced_num_rows = 1,
    layout = wibox.layout.grid
}

awful.widget.watch("bash -c 'cat /sys/class/net/" .. get_device() .. "/statistics/tx_bytes 2>/dev/null && cat /sys/class/net/" .. get_device() .. "/statistics/rx_bytes 1>&2'", network_widget.time_interval,
    function(widget, stdout, stderr, exitreason, exitcode)
        send_bytes = trim(stdout)
        received_bytes = trim(stderr)
        if widget.last_sent then
            network_widget.send.markup = "<span size='xx-large'>" ..
                "<b>" ..
                    math.floor(
                        (tonumber(send_bytes) - network_widget.last_sent) / 1024 / network_widget.time_interval
                    ) ..
                "</b>" ..
            "</span>"
        end
        if widget.last_receive then
            network_widget.receive.markup = "<span size='xx-large'>" ..
                "<b>" ..
                    math.floor(
                        (tonumber(received_bytes) - network_widget.last_receive) / 1024 / network_widget.time_interval
                    ) ..
                "</b>" ..
            "</span>"
        end
        widget.last_sent = send_bytes
        widget.last_receive = received_bytes
    end,
    network_widget
)

return network_layout
