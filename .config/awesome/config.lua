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
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier,
    awful.layout.suit.corner.nw,
    awful.layout.suit.floating,
    -- awful.layout.suit.corner.ne,
    -- awful.layout.suit.corner.sw,
    -- awful.layout.suit.corner.se,
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
    -- TODO: focus other monitor relative to index
    awful.key(
        { modkey }, "h", function() awful.screen.focus_bydirection("left") end,
        { description = "focus the screen to the left", group = "screen" }
    ),
    awful.key(
        { modkey }, "l", function() awful.screen.focus_bydirection("right") end,
        { description = "focus the screen to the right", group = "screen" }
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
    -- TODO: send client to other monitor relative to index
    awful.key(
        { modkey, "Shift" }, "h", function(c) awful.client.movetoscreen(c, c.screen:get_next_in_direction("left")) end,
        { description = "send client to screen to the left", group = "client" }
    ),
    awful.key(
        { modkey, "Shift" }, "l", function(c) awful.client.movetoscreen(c, c.screen:get_next_in_direction("right")) end,
        { description = "send client to screen to the right", group = "client" }
    ),
    awful.key(
        { modkey }, "w", function(c) c:kill() end,
        { description = "close", group = "client" }
    )
)

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
