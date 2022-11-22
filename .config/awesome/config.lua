-- Imports
local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")

-- Stuff
local terminal = "alacritty"
local editor = os.getenv("EDITOR") or "nano"
local modkey = "Mod4"
local altkey = "Mod1"

local battery_dir = "/sys/class/power_supply/BAT1"

-- Tags
local tags = { "1", "2", "3", "4", "5", "6", "7", "8", "9" }

-- Layouts
local layouts = {
    awful.layout.suit.fair,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.floating,
}

-- Widgets & status bar
local separators = {
    space = wibox.widget {
        forced_width = 3,
    },

    pipe = wibox.widget {
        orientation = "vertical",
        thickness = 1,
        span_ratio = 0.5,
        forced_width = 7,
        widget = wibox.widget.separator,
    },
}

local battery = awful.widget.watch(
    "sh -c 'cat " .. battery_dir .. "/capacity; cat " .. battery_dir .. "/status'",
    5,
    function(widget, stdout, stderr)
        local label = "Battery: "

        if stderr ~= "" then widget:set_markup(label .. "N/A"); return end

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

        if stderr ~= "" then widget:set_markup(label .. "N/A"); return end

        local stdout_lines = { }
        for v in string.gmatch(stdout, "[^\n]+") do table.insert(stdout_lines, v) end

        widget:set_markup(label .. stdout_lines[1] .. "%")
    end
)

local volume, volume_timer = awful.widget.watch(
    "sh -c 'pactl get-sink-volume @DEFAULT_SINK@ | cut -s -d/ -f2,4; pactl get-sink-mute @DEFAULT_SINK@'",
    5, -- timeout 
    function(widget, stdout, stderr)
        local label = "Volume: "

        if stderr ~= "" then widget:set_markup(label .. "N/A"); return end

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

local date = wibox.widget.textclock("%a, %b %d, %Y %-l:%M %p")

local status_bar = {
    layout = wibox.layout.fixed.horizontal,
    separators.space,
    battery,
    separators.pipe,
    brightness,
    separators.pipe,
    volume,
    separators.pipe,
    date,
    separators.space,
}

-- {{{ Keybinds
local keybinds = gears.table.join(
    -- Launcher keybinds
    awful.key(
        { modkey }, "Return", function() awful.spawn(terminal) end,
        { description = "spawn a terminal", group = "launcher" }
    ),
    awful.key(
        { modkey }, "m", function() os.execute("rofi -show drun") end,
        { description = "run the rofi launcher", group = "launcher" }
    ),

    -- Screen keybinds
    awful.key(
        { modkey }, "j", function() awful.client.focus.byidx(1) end,
        { description = "focus next client by index", group = "screen" }
    ),
    awful.key(
        { modkey }, "k", function() awful.client.focus.byidx(-1) end,
        { description = "focus previous client by index", group = "screen" }
    ),
    awful.key(
        { modkey }, "h", function() awful.screen.focus_relative(-1) end,
        { description = "focus the previous screen", group = "screen" }
    ),
    awful.key(
        { modkey }, "l", function() awful.screen.focus_relative(1) end,
        { description = "focus the next screen", group = "screen" }
    ),
    awful.key(
        { modkey }, "Tab", function() awful.layout.inc(1) end,
        { description = "switch to next layout", group = "layout" }
    ),
    awful.key(
        { modkey, "Shift" }, "Tab", function() awful.layout.inc(-1) end,
        { description = "switch to previous layout", group = "layout" }
    ),
    awful.key(
        { modkey, "Control" }, "r", awesome.restart,
        { description = "reload awesome", group = "screen" }
    ),
    awful.key(
        { modkey, "Control" }, "q", awesome.quit,
        { description = "quit awesome", group = "screen" }
    ),

    -- Other
    awful.key(
        { }, "XF86AudioRaiseVolume",
        function()
            os.execute("pactl -- set-sink-volume @DEFAULT_SINK@ +5%")
            volume_timer:emit_signal("timeout")
        end,
        { description = "raise the volume", group = "other" }
    ),
    awful.key(
        { }, "XF86AudioLowerVolume",
        function()
            os.execute("pactl -- set-sink-volume @DEFAULT_SINK@ -5%")
            volume_timer:emit_signal("timeout")
        end,
        { description = "lower the volume", group = "other" }
    ),
    awful.key(
        { }, "XF86AudioMute",
        function()
            os.execute("pactl -- set-sink-mute @DEFAULT_SINK@ toggle")
            volume_timer:emit_signal("timeout")
        end,
        { description = "toggle mute volume", group = "other" }
    ),
    awful.key(
        { }, "XF86MonBrightnessUp",
        function()
            os.execute("light -A 10")
            brightness_timer:emit_signal("timeout")
        end,
        { description = "raise the brightness", group = "other" }
    ),
    awful.key(
        { }, "XF86MonBrightnessDown",
        function()
            os.execute("light -U 10")
            brightness_timer:emit_signal("timeout")
        end,
        { description = "lower the brightness", group = "other" }
    )
);

-- Add a keybind to view each tag
for i = 1, 9 do
    keybinds = gears.table.join(
        keybinds,

        -- View tag only.
        awful.key(
            { modkey }, "#" .. i + 9, function()
                local screen = awful.screen.focused()
                local tag = screen.tags[i]
                if tag then
                    tag:view_only()
                end
            end,
            {description = "view tag #" .. i, group = "tag"}
        )
    )
end

local client_keybinds = gears.table.join(
    awful.key(
        { modkey, "Shift" }, "j", function() awful.client.swap.byidx(1) end,
        { description = "swap with next client by index", group = "client" }
    ),
    awful.key(
        { modkey, "Shift" }, "k", function() awful.client.swap.byidx(-1) end,
        { description = "swap with previous client by index", group = "client" }
    ),
    awful.key(
        { modkey, "Shift" }, "h", function(c) c:move_to_screen(c.screen.index - 1) end,
        { description = "send client to previous screen", group = "client" }
    ),
    awful.key(
        { modkey, "Shift" }, "l", function(c) c:move_to_screen(c.screen.index + 1) end,
        { description = "send client to next screen", group = "client" }
    ),
    awful.key(
        { modkey }, "w", function(c) c:kill() end,
        { description = "close", group = "client" }
    )
)

-- Add a keybind to send the focused client to the corresponding tag.
for i = 1, 9 do
    client_keybinds = gears.table.join(
        client_keybinds,

        -- Send client to tag.
        awful.key(
            { modkey, "Shift" }, "#" .. i + 9, function(c)
                local screen = awful.screen.focused()
                local tag = screen.tags[i]
                if tag then
                    c:move_to_tag (tag)
                end
            end,
            {description = "move client to tag #" .. i, group = "tag"}
        )
    )
end

local client_buttons = gears.table.join(
    awful.button({ }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
    end),
    awful.button({ modkey }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.move(c)
    end),
    awful.button({ modkey }, 2, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.client.floating.toggle()
    end),
    awful.button({ modkey }, 3, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.resize(c)
    end)
)
-- }}}

return {
    terminal = terminal,
    editor = editor,
    editor_cmd = terminal .. " -e " .. editor,
    modkey = modkey,
    altkey = altkey,
    tags = tags,
    layouts = layouts,
    status_bar = status_bar,
    separators = separators,
    keybinds = keybinds,
    client_keybinds = client_keybinds,
    client_buttons = client_buttons,
}
