local naughty = require("naughty")

local defaultOutput = 'eDP1'

outputMapping = {
    ['DP-1'] = 'DP1',
    ['DP-2'] = 'DP2',
    ['DP-3'] = 'DP3',
    ['VGA-1'] = 'VGA1',
    ['LVDS-1'] = 'LVDS1',
    ['HDMI-A-1'] = 'HDMI1',
    ['HDMI-A-2'] = 'HDMI2',
    ['eDP-1'] = 'eDP1',
    ['eDP-2'] = 'eDP2',
    ['VIRTUAL1'] = 'VIRTUAL1',
}

screens = {
	['default'] = {
		['connected'] = function (xrandrOutput)
            if xrandrOutput ~= defaultOutput then
                return '--output ' .. xrandrOutput .. ' --auto --same-as ' .. defaultOutput
            end
            return nil
		end,
		['disconnected'] = function (xrandrOutput)
            if xrandrOutput ~= defaultOutput then
                return '--output ' .. xrandrOutput .. ' --off --output ' .. defaultOutput .. ' --auto'
            end
            return nil
		end
	},
    ['135686909043'] = { -- HDMI2
        ['connected'] = function (xrandrOutput)
            if xrandrOutput ~= defaultOutput then
                return '--output ' .. xrandrOutput .. ' --auto --right-of ' .. defaultOutput
            end
            return nil
        end,
        ['disconnected'] = function (xrandrOutput)
            if xrandrOutput ~= defaultOutput then
            return '--output ' .. xrandrOutput .. ' --off --output ' .. defaultOutput .. ' --auto'
            end
            return nil
        end
    }
}

return {
    outputMapping = outputMapping,
    screens = screens
}
--	['500000'] = { -- eDP1
--		['connected'] = function (xrandrOutput)
--			if xrandrOutput ~= defaultOutput then
--				return '--output ' .. xrandrOutput .. ' --auto --same-as ' .. defaultOutput
--			end
--			return nil
--		end,
--		['disconnected'] = function (xrandrOutput)
--			if xrandrOutput ~= defaultOutput then
--			return '--output ' .. xrandrOutput .. ' --off --output ' .. defaultOutput .. ' --auto'
--			end
--			return nil
--		end
--	}
