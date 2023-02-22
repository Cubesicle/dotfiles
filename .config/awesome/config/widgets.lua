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
    { "quit", function() awesome.quit() end },
}

local power_menu = {
    { "poweroff", "sh -c 'loginctl poweroff'" },
    { "reboot", "sh -c 'loginctl reboot'" },
    { "suspend", "sh -c 'loginctl suspend'" },
    { "hibernate", "sh -c 'loginctl hibernate'" },
}

local main_menu = awful.menu({
    items = {
        { "awesome", awesome_menu, beautiful.awesome_icon },
        { "power", power_menu },
        { "open terminal", general.terminal },
        { "rofi launcher", "sh -c 'sleep 0.15; rofi -show drun'" },
    },
})

-- Bar widgets
local function wrap_in_powerline(widget, fg_color, bg_color, is_end)
    local shape = gears.shape.rectangular_tag
    if is_end then
        shape = function(cr, width, height) gears.shape.powerline(cr, width, height, height/-2) end
    end
    return wibox.widget {
        wibox.widget {
            widget,
            left = dpi(general.bar_height/2 + general.widget_spacing),
            right = dpi(general.bar_height/2 + general.widget_spacing),
            widget = wibox.container.margin,
        },
        fg = fg_color,
        bg = bg_color,
        shape = shape,
        widget = wibox.container.background,
    }
end

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
        style   = {
            shape = function(cr, width, height) gears.shape.powerline(cr, width, height, height/-2) end,
        },
        layout   = {
            spacing = dpi(general.bar_height/-2),
            layout  = wibox.layout.flex.horizontal
        },
        widget_template = {
            {
                {
                    {
                        {
                            id     = 'icon_role',
                            widget = wibox.widget.imagebox,
                        },
                        margins = dpi(2),
                        widget  = wibox.container.margin,
                    },
                    {
                        id     = 'text_role',
                        widget = wibox.widget.textbox,
                    },
                    layout = wibox.layout.fixed.horizontal,
                },
                left  = dpi(general.bar_height/2 + general.widget_spacing),
                right = dpi(general.bar_height/2 + general.widget_spacing),
                widget = wibox.container.margin
            },
            id     = 'background_role',
            widget = wibox.container.background,
        },
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
            right = dpi(general.widget_spacing),
            widget = wibox.container.margin,
        },
        visible = false,
        layout = wibox.layout.fixed.horizontal,
    }

    local systray_and_layoutbox = wibox.widget {
        systray_container,
        layoutbox,
        layout = wibox.layout.fixed.horizontal,
    }

    systray_and_layoutbox:connect_signal("mouse::enter", function() systray:set_screen(mouse.screen) systray_container.visible = true end)
    systray_and_layoutbox:connect_signal("mouse::leave", function() systray_container.visible = false end)

    return systray_and_layoutbox
end

local status_bar = wibox.widget {
    wrap_in_powerline(battery,    beautiful.fg_focus, beautiful.colors.red),
    wrap_in_powerline(brightness, beautiful.fg_focus, beautiful.colors.maroon),
    wrap_in_powerline(volume,     beautiful.fg_focus, beautiful.colors.peach),
    wrap_in_powerline(date,       beautiful.fg_focus, beautiful.colors.yellow, true),
    spacing = dpi(general.bar_height/-2),
    layout = wibox.layout.fixed.horizontal,
}

widgets.bar = function(s)
    local bar = awful.wibar({
        height = dpi(general.bar_height),
        position = "top",
        screen = s,
    })
    bar:setup {
        {
            launcher,
            {
                new_taglist(s),
                left = dpi(general.widget_spacing),
                right = dpi(general.widget_spacing),
                widget = wibox.container.margin,
            },
            layout = wibox.layout.fixed.horizontal,
        },
            new_tasklist(s),
        {
            nil,
            {
                status_bar,
                left = dpi(general.widget_spacing),
                right = dpi(general.widget_spacing),
                widget = wibox.container.margin,
            },
            new_systray_and_layoutbox(s),
            layout = wibox.layout.align.horizontal,
        },
        layout = wibox.layout.align.horizontal,
    }
    return bar
end

return widgets
