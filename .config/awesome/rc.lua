-- Imports
pcall(require, "luarocks.loader")

local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")


require("awful.autofocus")
require("awful.hotkeys_popup.keys")

local config = require("config")

-- Disable naughty if it's disabled in the config
if not config.general.enable_naughty then package.loaded["naughty.dbus"] = {} end
local naughty = require("naughty")

-- Functions
local function sort_screens()
    -- Count number of screens
    local screens = screen:count()
    -- Make a table of screen indexes sorted by screen x position
    local sorted_screens = { }
    for s in screen do
        table.insert(sorted_screens, { index = s.index, x = s.geometry.x })
    end
    table.sort(sorted_screens, function(a, b) return a.x < b.x end)

    -- Add as many fake screens as there are real screens
    for _ = 1, screens, 1 do
        screen.fake_add(0, 0, 0, 0)
    end

    -- Reorder the screens using the sorted_screens table
    for k, v in pairs(sorted_screens) do
        screen[v.index]:swap(screen[k + screens])
    end

    -- Remove the fake screens
    for _ = 1, screens, 1 do
        screen[1]:fake_remove()
    end
end

local function notify(title, message, urgency)
    local preset;
    if     urgency == "low"      then preset = naughty.config.presets.low
    elseif urgency == "normal"   then preset = naughty.config.presets.normal
    elseif urgency == "critical" then preset = naughty.config.presets.critical end

    if config.general.enable_naughty then
        naughty.notify({
            preset = preset,
            title = title,
            text = message,
        })
    else
        os.execute("notify-send -u " .. urgency .. " '" .. title .. "' '" .. message .. "'")
    end
end

-- Error handling
if awesome.startup_errors then
    notify("Oops, there were errors during startup!", awesome.startup_errors, "critical")
end

do
    local in_error = false
    awesome.connect_signal("debug::error", function(err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        notify("Oops, an error happened!", tostring(err), "critical")
        in_error = false
    end)
end


-- Set theme
beautiful.init(gears.filesystem.get_configuration_dir() .. "/themes/" .. config.general.theme)

-- Set Layouts
awful.layout.layouts = config.general.layouts

-- Set keys
root.keys(config.keybinds.global)

-- Set notification border width (this is a workaround for a bug in the naughty library)
naughty.config.defaults.border_width = beautiful.notification_border_width

-- Sort screens
sort_screens()

-- Launch startup script
os.execute("sh -c '~/.config/awesome/autorun.sh'")

-- Display widgets on all screens
awful.screen.connect_for_each_screen(function(s)
    -- Set tag table for each screen
    awful.tag(config.general.tags, s, awful.layout.layouts[1])

    -- Add a bar for each screen
    config.widgets.bar(s)
end)

-- Rules
awful.rules.rules = {
    {
        rule = { },
        properties = {
            border_width = beautiful.border_width,
            border_color = beautiful.border_normal,
            focus = awful.client.focus.filter,
            raise = true,
            keys = config.keybinds.client,
            buttons = config.keybinds.client_buttons,
            screen = awful.screen.preferred,
            placement = awful.placement.no_overlap+awful.placement.no_offscreen
        },
    },
}

-- Enable sloppy focus
client.connect_signal("mouse::enter", function(c)
    c:emit_signal("request::activate", "mouse_enter", { raise = false })
end)

-- Prevent minimize and maximize
client.connect_signal("property::minimized", function(c)
    c.minimized = false
end)

client.connect_signal("property::maximized", function(c)
    c.maximized = false
end)

-- Set client borders
client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
