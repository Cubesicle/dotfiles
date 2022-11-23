-- Imports
pcall(require, "luarocks.loader")

local awful = require("awful")
local gears = require("gears")
local naughty = require("naughty")
local beautiful = require("beautiful")

require("awful.autofocus")
require("awful.hotkeys_popup.keys")

local config = require("config")

-- Set theme
beautiful.init(gears.filesystem.get_configuration_dir() .. "/themes/" .. config.general.theme)

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

local function set_wallpaper(s)
    -- Wallpaper
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end
end

-- Error handling
if awesome.startup_errors then
    naughty.notify({
        preset = naughty.config.presets.critical,
        title = "Oops, there were errors during startup!",
        text = awesome.startup_errors,
    })
end

do
    local in_error = false
    awesome.connect_signal("debug::error", function(err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({
            preset = naughty.config.presets.critical,
            title = "Oops, an error happened!",
            text = tostring(err)
        })
        in_error = false
    end)
end

-- Set Layouts
awful.layout.layouts = config.general.layouts

-- Set keys
root.keys(config.keybinds.global)

-- Sort screens
sort_screens()

-- Display widgets on all screens
awful.screen.connect_for_each_screen(function(s)
    -- Set the wallpaper
    set_wallpaper(s)

    -- Set tag table for each screen
    awful.tag(config.general.tags, s, awful.layout.layouts[1])

    -- Create the bar
    s.bar = awful.wibar({ position = "top", screen = s })

    -- Add widgets to the bar
    config.widgets.setup_bar(s.bar)
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
    c:emit_signal("request::activate", "mouse_enter", {raise = false})
end)

-- Set client borders
client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
