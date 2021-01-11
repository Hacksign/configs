local naughty = require("naughty")

local defaultOutput = 'eDP-1'

outputMapping = {
    ['DP-1'] = 'DP-1',
    ['DP-2'] = 'DP-2',
    ['DP-3'] = 'DP-3',
    ['DP-4'] = 'DP-2-1',
    ['DP-5'] = 'DP-2-2',
    ['DP-6'] = 'DP-2-3',
    ['VGA-1'] = 'VGA1',
    ['LVDS-1'] = 'LVDS1',
    ['HDMI-A-1'] = 'HDMI1',
    ['HDMI-A-2'] = 'HDMI2',
    ['eDP-1'] = 'eDP-1',
    ['eDP-2'] = 'eDP-2',
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
    ['97111123'] = { -- DP-2-1
    	['connected'] = function (xrandrOutput)
    		if xrandrOutput ~= defaultOutput then
    			return '--output ' .. xrandrOutput .. ' --auto --left-of ' .. defaultOutput
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
    ['0000010'] = { -- DP-2-2
    	['connected'] = function (xrandrOutput)
    		if xrandrOutput ~= defaultOutput then
    			return '--output ' .. xrandrOutput .. ' --auto --below DP-2-1'
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
--	['3600000'] = { -- eDP-1
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
--	['1608368715250'] = { -- HDMI2
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
--	['3400001'] = { -- HDMI2
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
