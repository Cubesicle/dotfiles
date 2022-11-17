-- Imports
pcall(require, "luarocks.loader")

local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")

local wibox = require("wibox")

local beautiful = require("beautiful")

local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")

require("awful.hotkeys_popup.keys")

local config = require("config");

-- Functions
local debug_print = function(message)
    naughty.notify({
        title = "Debug",
        text = tostring(message),
    })
end

-- TODO: fix this shit
local sort_screens = function()
    local screens = 0 -- The number of screens

    local sorted_screens = { } -- An array of screen indexes sorted by x position
    for s in screen do
        screens = screens + 1 -- Increase the screen variable every time it finds a screen
        table.insert(sorted_screens, { index = s.index, x = s.geometry.x }) -- Fill up the sorted_screens table
    end
    table.sort(sorted_screens, function(a, b) return a.x < b.x end) -- Sort the screens by x position

    for _ = 1, screens, 1 do
        screen.fake_add(0, 0, 0, 0) -- Add as many fake screens as there are real screens (value of screens will double)
    end
    for i = 1, screens, 1 do
        screen[i]:swap(screen[sorted_screens[i].index + screens]) -- Swap out the fake screens with real screens using the indexes in the sorted_screens table
        debug_print(i .. "->" .. sorted_screens[i].index)
    end
    for _ = 1, screens, 1 do
        screen[1]:fake_remove() -- Remove the fake screens
    end
    debug_print(gears.debug.dump_return(sorted_screens))
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

-- Set theme 
beautiful.init(gears.filesystem.get_themes_dir() .. "default/theme.lua")

-- Set Layouts
awful.layout.layouts = config.layouts

-- Set keys
root.keys(config.keybinds)

-- Sort screens
-- sort_screens()

-- {{{ User Interface
-- Display widgets on all screens
awful.screen.connect_for_each_screen(function(s)
    -- Set tag table for each screen
    awful.tag(config.tags, s, awful.layout.layouts[1])

    -- Create a taglist widget
    s.taglist = awful.widget.taglist {
        screen  = s,
        filter  = awful.widget.taglist.filter.all,
        buttons = gears.table.join(
            awful.button({ }, 1, function(tag) tag:view_only() end)
        )
    }

    -- Create a tasklist widget
    s.tasklist = awful.widget.tasklist {
        screen  = s,
        filter  = awful.widget.tasklist.filter.currenttags,
        buttons = gears.table.join(
            awful.button({ }, 1, function(c)
                c:emit_signal(
                    "request::activate",
                    "tasklist",
                    { raise = true }
                )
            end),
            awful.button({ }, 2, function(c) c:kill() end)
        )
    }

    -- Create the bar
    s.bar = awful.wibar({ position = "top", screen = s })

    -- Add widgets to the wibox
    s.bar:setup {
        layout = wibox.layout.align.horizontal,

        -- Left widgets
        {
            layout = wibox.layout.fixed.horizontal,
            s.taglist,
            --s.mylayoutbox,
            wibox.widget{
                markup = " Screen #" .. s.index .. " x: " .. s.geometry.x .. " y: " .. s.geometry.y,
                align  = "center",
                valign = "center",
                widget = wibox.widget.textbox,
            },
        },

        -- Middle widget
        s.tasklist,

        -- Right widgets
        {
            layout = wibox.layout.fixed.horizontal,
            wibox.widget.textclock("%b %d, %Y %l:%M %p"),
            wibox.widget.systray(),
        },
    }
end)
-- }}}

-- Rules
awful.rules.rules = {
    {
        rule = { },
        properties = {
            border_width = beautiful.border_width,
            border_color = beautiful.border_normal,
            focus = awful.client.focus.filter,
            raise = true,
            keys = config.client_keybinds,
            buttons = config.client_buttons,
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
