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

-- {{{ User Interface
-- Display widgets on all screens
awful.screen.connect_for_each_screen(function(screen)
    -- Set tag table for each screen
    awful.tag(config.tags, screen, awful.layout.layouts[1])

    -- Create a taglist widget
    screen.taglist = awful.widget.taglist {
        screen  = screen,
        filter  = awful.widget.taglist.filter.all,
        buttons = gears.table.join(
            awful.button({ }, 1, function(tag) tag:view_only() end),
            awful.button({ config.modkey }, 1, function(tag)
                if client.focus then
                    client.focus:move_to_tag(tag)
                end
            end),
            awful.button({ }, 3, awful.tag.viewtoggle),
            awful.button({ config.modkey }, 3, function(tag)
                if client.focus then
                    client.focus:toggle_tag(tag)
                end
            end),
            awful.button({ }, 4, function(tag) awful.tag.viewnext(tag.screen) end),
            awful.button({ }, 5, function(tag) awful.tag.viewprev(tag.screen) end)
        )
    }

    -- Create a tasklist widget
    screen.tasklist = awful.widget.tasklist {
        screen  = screen,
        filter  = awful.widget.tasklist.filter.currenttags,
        buttons = gears.table.join(
            awful.button({ }, 1, function(c)
                if c == client.focus then
                    c.minimized = true
                else
                c:emit_signal(
                    "request::activate",
                    "tasklist",
                    {raise = true}
                    )
                end
            end),
            awful.button({ }, 3, function()
                awful.menu.client_list({ theme = { width = 250 } })
            end),
            awful.button({ }, 4, function()
                awful.client.focus.byidx(1)
            end),
            awful.button({ }, 5, function()
                awful.client.focus.byidx(-1)
            end)
        )
    }

    -- Create the bar
    screen.bar = awful.wibar({ position = "top", screen = screen })

    -- Add widgets to the wibox
    screen.bar:setup {
        layout = wibox.layout.align.horizontal,

        -- Left widgets
        {
            layout = wibox.layout.fixed.horizontal,
            screen.taglist,
            --screen.mylayoutbox,
        },

        -- Middle widget
        screen.tasklist,

        -- Right widgets
        {
            layout = wibox.layout.fixed.horizontal,
            wibox.widget.textclock("%b %d, %Y %l:%M %p"),
            wibox.widget.systray(),
        },
    }
end)
-- }}}
