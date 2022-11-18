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

local sort_screens = function()
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
sort_screens()

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

    -- Create a layout box widget
    s.layoutbox = awful.widget.layoutbox(s)
    s.layoutbox:buttons(gears.table.join(
        awful.button({ }, 1, function() awful.layout.inc( 1) end),
        awful.button({ }, 3, function() awful.layout.inc(-1) end)
    ))

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

    -- Status widgets
    s.test = wibox.widget {
        markup = "jsdflkajsdf",
        widget = wibox.widget.textbox,
    }

    -- Separators
    s.space_separator = wibox.widget {
        forced_width = 3,
    }

    s.pipe_separator = wibox.widget {
        orientation = "vertical",
        thickness = 1,
        span_ratio = 0.5,
        forced_width = 7,
        widget = wibox.widget.separator,
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
            s.space_separator,
            s.layoutbox,
            s.space_separator,
        },

        -- Middle widget
        s.tasklist,

        -- Right widgets
        {
            layout = wibox.layout.fixed.horizontal,
            s.space_separator,
            s.test,
            s.pipe_separator,
            wibox.widget.textclock("%b %d, %Y%l:%M %p"),
            s.space_separator,
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
