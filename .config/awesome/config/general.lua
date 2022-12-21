-- Imports
local awful = require("awful")

local general = { }

-- Stuff
general.modkey         = "Mod4"
general.battery_dir    = "/sys/class/power_supply/BAT1"
general.theme          = "catppuccin/theme.lua"
general.terminal       = "kitty"
general.editor         = os.getenv("EDITOR") or "nano"
general.editor_cmd     = general.terminal .. " -e " .. general.editor
general.enable_naughty = false
general.bar_height     = 23
general.widget_spacing = 7

-- Tags
general.tags = { "1", "2", "3", "4", "5", "6", "7", "8", "9" }

-- Layouts
general.layouts = {
    awful.layout.suit.fair,
    awful.layout.suit.max,
    awful.layout.suit.floating,
}

return general
