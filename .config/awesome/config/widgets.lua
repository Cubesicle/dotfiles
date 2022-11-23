-- Imports
local awful = require("awful")
local beautiful = require("beautiful")
local gears = require("gears")
local wibox = require("wibox")
local hotkeys_popup = require("awful.hotkeys_popup")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

local general = require("config.general")

local widgets = { }
widgets.timers = { }

-- Set theme
beautiful.init(gears.filesystem.get_configuration_dir() .. "/themes/" .. general.theme)

-- Menu
local awesome_menu = {
    { "hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
    { "manual", general.terminal .. " -e man awesome" },
    { "restart", awesome.restart },
    { "quit", function() awesome.quit() end }
}

local main_menu = awful.menu({
    items = {
        { "awesome", awesome_menu, beautiful.awesome_icon },
        { "open terminal", general.terminal },
        { "rofi launcher", "sh -c 'sleep 0.15; rofi -show drun'" },
    },
})

-- Bar widgets
local function wrap_in_container(widget, fg_color, bg_color, shape)
    return wibox.widget {
        {
            widget,
            layout = wibox.layout.fixed.horizontal,
        },
        fg = fg_color,
        bg = bg_color,
        shape = shape or gears.shape.rectangle,
        widget = wibox.container.background,
    }
end

widgets.separators = {
    space = function(bg_color)
        if not bg_color then
            return wibox.widget {
                forced_width = dpi(7),
            }
        else
            return wibox.widget {
                {
                    forced_width = dpi(7),
                    layout = wibox.layout.fixed.horizontal,
                },
                bg = bg_color,
                widget = wibox.container.background,
            }
        end
    end,

    powerline = function(fg_color, bg_color)
        return wrap_in_container(
            wibox.widget {
                shape = gears.shape.rectangular_tag,
                forced_width = dpi(12),
                widget = wibox.widget.separator,
            },
            fg_color,
            bg_color
        )
    end,
}

local launcher = awful.widget.launcher({
    image = beautiful.awesome_icon, menu = main_menu
})

local battery = awful.widget.watch(
    "sh -c 'cat " .. general.battery_dir .. "/capacity; cat " .. general.battery_dir .. "/status'",
    5,
    function(widget, stdout, stderr)
        local label = "Battery: "

        if stderr ~= "" then widget:set_markup(label .. "N/A") return end

        local stdout_lines = { }
        for v in string.gmatch(stdout, "[^\n]+") do table.insert(stdout_lines, v) end

        widget:set_markup(label .. stdout_lines[1] .. "% " .. stdout_lines[2])
    end
)

local brightness, brightness_timer = awful.widget.watch(
    "sh -c 'light -G'",
    5,
    function(widget, stdout, stderr)
        local label = "Brightness: "

        if stderr ~= "" then widget:set_markup(label .. "N/A") return end

        local stdout_lines = { }
        for v in string.gmatch(stdout, "[^\n]+") do table.insert(stdout_lines, v) end

        widget:set_markup(label .. stdout_lines[1] .. "%")
    end
)
widgets.timers.brightness_timer = brightness_timer

local volume, volume_timer = awful.widget.watch(
    "sh -c 'pactl get-sink-volume @DEFAULT_SINK@ | cut -s -d/ -f2,4; pactl get-sink-mute @DEFAULT_SINK@'",
    5, -- timeout 
    function(widget, stdout, stderr)
        local label = "Volume: "

        if stderr ~= "" then widget:set_markup(label .. "N/A") return end

        local volumes = { }
        for v in stdout:gmatch("(%d+%%)") do table.insert(volumes, v) end
        local mute = string.match(stdout, "Mute: (%S+)")

        -- customize here
        if mute == "yes" then
            widget:set_markup(label .. "muted")
        elseif volumes[1] == volumes[2] then
            widget:set_markup(label .. volumes[1])
        else
            widget:set_markup(label .. volumes[1] .. " / " .. volumes[2])
        end
    end
)
widgets.timers.volume_timer = volume_timer

local date = wibox.widget.textclock("%a, %b %d, %Y %-l:%M %p")

-- Screen-specific widgets
local function new_taglist(s)
    return awful.widget.taglist {
        screen  = s,
        filter  = awful.widget.taglist.filter.all,
        buttons = gears.table.join(
            awful.button({ }, 1, function(tag) tag:view_only() end)
        ),
    }
end

local function new_tasklist(s)
    return awful.widget.tasklist {
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
        ),
    }
end

local function new_systray_and_layoutbox(s)
    local systray = wibox.widget.systray()

    local layoutbox = awful.widget.layoutbox(s)
    layoutbox:buttons(gears.table.join(
        awful.button({ }, 1, function() awful.layout.inc( 1) end),
        awful.button({ }, 3, function() awful.layout.inc(-1) end)
    ))

    local systray_container = wibox.widget {
        {
            systray,
            widgets.separators.space(),
            layout = wibox.layout.fixed.horizontal,
        },
        visible = false,
        widget = wibox.container.background,
    }

    local systray_and_layoutbox = wibox.widget {
        {
            systray_container,
            layoutbox,
            layout = wibox.layout.fixed.horizontal,
        },
        widget = wibox.container.background,
    }

    systray_and_layoutbox:connect_signal("mouse::enter", function() systray:set_screen(mouse.screen) systray_container.visible = true end)
    systray_and_layoutbox:connect_signal("mouse::leave", function() systray_container.visible = false end)

    return systray_and_layoutbox
end

local status_bar = {
    widgets.separators.space(),

    widgets.separators.powerline("#f38ba8", beautiful.bg_normal),
    widgets.separators.space("#f38ba8"),
    wrap_in_container(battery, beautiful.fg_focus, "#f38ba8"),
    widgets.separators.space("#f38ba8"),

    widgets.separators.powerline("#eba0ac", "#f38ba8"),
    widgets.separators.space("#eba0ac"),
    wrap_in_container(brightness, beautiful.fg_focus, "#eba0ac"),
    widgets.separators.space("#eba0ac"),

    widgets.separators.powerline("#fab387", "#eba0ac"),
    widgets.separators.space("#fab387"),
    wrap_in_container(volume, beautiful.fg_focus, "#fab387"),
    widgets.separators.space("#fab387"),

    widgets.separators.powerline("#f9e2af", "#fab387"),
    widgets.separators.space("#f9e2af"),
    wrap_in_container(date, beautiful.fg_focus, "#f9e2af"),
    widgets.separators.space("#f9e2af"),

    widgets.separators.powerline(beautiful.bg_normal, "#f9e2af"),
    widgets.separators.space(),
    layout = wibox.layout.fixed.horizontal,
}

widgets.setup_bar = function(b)
    local s = b.screen
    b:setup {
        layout = wibox.layout.align.horizontal,

        -- Left widgets
        {
            launcher,
            widgets.separators.space(),
            new_taglist(s),
            widgets.separators.space(),
            layout = wibox.layout.fixed.horizontal,
        },

        -- Middle widget
        new_tasklist(s),

        -- Right widgets
        {
            wibox.widget {
                status_bar,
                widget = wibox.container.background,
            },
            new_systray_and_layoutbox(s),
            layout = wibox.layout.fixed.horizontal,
        },
    }
end

return widgets
