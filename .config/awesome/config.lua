-- Imports
local awful = require("awful")
local gears = require("gears")

-- Stuff
local terminal = "xterm"
local editor = os.getenv("EDITOR") or "nano"
local modkey = "Mod4"

-- Tags
local tags = { "1", "2", "3", "4", "5", "6", "7", "8", "9" }

-- Layouts
local layouts = {
    awful.layout.suit.floating,
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
    -- awful.layout.suit.corner.ne,
    -- awful.layout.suit.corner.sw,
    -- awful.layout.suit.corner.se,
}

-- Keybinds
local keybinds = gears.table.join();

for i = 1, 9 do
    keybinds = gears.table.join(
        keybinds,

        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9, function()
            local screen = awful.screen.focused()
            local tag = screen.tags[i]
            if tag then
                tag:view_only()
            end
        end,
        {description = "view tag #" .. i, group = "tag"}),

        -- Toggle tag display.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
        function ()
        local screen = awful.screen.focused()
        local tag = screen.tags[i]
        if tag then
        awful.tag.viewtoggle(tag)
        end
        end,
        {description = "toggle tag #" .. i, group = "tag"}),

        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
        function ()
        if client.focus then
        local tag = client.focus.screen.tags[i]
        if tag then
        client.focus:move_to_tag(tag)
        end
        end
        end,
        {description = "move focused client to tag #"..i, group = "tag"}),

        -- Toggle tag on focused client.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
        function ()
        if client.focus then
        local tag = client.focus.screen.tags[i]
        if tag then
        client.focus:toggle_tag(tag)
        end
        end
        end,
        {description = "toggle focused client on tag #" .. i, group = "tag"})
    )
end

return {
    terminal = terminal,
    editor = editor,
    editor_cmd = terminal .. " -e " .. editor,
    modkey = modkey,
    tags = tags,
    layouts = layouts,
}
