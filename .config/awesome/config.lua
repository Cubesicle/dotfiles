-- Imports
local awful = require("awful")
local gears = require("gears")

-- Stuff
local terminal = "alacritty"
local editor = os.getenv("EDITOR") or "nano"
local modkey = "Mod4"
local altkey = "Mod1"

-- Tags
local tags = { "1", "2", "3", "4", "5", "6", "7", "8", "9" }

-- Layouts
local layouts = {
    awful.layout.suit.fair,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.floating,
}

-- {{{ Keybinds
local keybinds = gears.table.join(
    -- Launcher keybinds
    awful.key(
        { modkey }, "Return", function() awful.spawn(terminal) end,
        { description = "spawn a terminal", group = "launcher" }
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
    keybinds = keybinds,
    client_keybinds = client_keybinds,
    client_buttons = client_buttons,
}
