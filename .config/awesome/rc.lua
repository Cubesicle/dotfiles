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
-- Menu
local awesome_menu = {
    { "hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
    { "manual", config.terminal .. " -e man awesome" },
    { "restart", awesome.restart },
    { "quit", function() awesome.quit() end }
}

local main_menu = awful.menu({
    items = {
        { "awesome", awesome_menu, beautiful.awesome_icon },
        { "open terminal", config.terminal },
    },
})

-- Launcher
local launcher = awful.widget.launcher({
    image = beautiful.awesome_icon, menu = main_menu
})

-- Expandable systray
local systray = wibox.widget.systray()

local systray_container = wibox.widget {
    {
        systray,
        config.separators.space,
        layout = wibox.layout.fixed.horizontal,
    },
    visible = false,
    widget = wibox.container.background,
}

-- Display widgets on all screens
awful.screen.connect_for_each_screen(function(s)
    -- {{{ Screen-specific widgets
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

    -- Layout box + expandable systray
    s.systray_show_area = wibox.widget {
        {
            systray_container,
            s.layoutbox,
            layout = wibox.layout.fixed.horizontal,
        },
        widget = wibox.container.background,
    }

    s.systray_show_area:connect_signal("mouse::enter", function() systray:set_screen(mouse.screen) systray_container.visible = true end)
    s.systray_show_area:connect_signal("mouse::leave", function() systray_container.visible = false end)

    -- Create the bar
    s.bar = awful.wibar({ position = "top", screen = s })

    -- Add widgets to the wibox
    s.bar:setup {
        layout = wibox.layout.align.horizontal,

        -- Left widgets
        {
            layout = wibox.layout.fixed.horizontal,
            launcher,
            s.taglist,
        },

        -- Middle widget
        s.tasklist,

        -- Right widgets
        {
            layout = wibox.layout.fixed.horizontal,
            wibox.widget {
                config.status_bar,
                widget = wibox.container.background,
            },
            s.systray_show_area,
        },
    }
    -- }}}
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

-- {{{ Event handlers
-- Enable sloppy focus
client.connect_signal("mouse::enter", function(c)
    c:emit_signal("request::activate", "mouse_enter", {raise = false})
end)

-- Set client borders
client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}
