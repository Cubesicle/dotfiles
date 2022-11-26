---------------------------
-- Default awesome theme --
---------------------------

local theme_assets = require("beautiful.theme_assets")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

local gfs = require("gears.filesystem")
local default_themes_path = gfs.get_themes_dir()
local theme_path = gfs.get_configuration_dir() .. "/themes/catppuccin"

local theme = { }

theme.font = "JetBrainsMono Nerd Font Bold 8"

theme.colors = { }
theme.colors.rosewater = "#f5e0dc"
theme.colors.flamingo  = "#f2cdcd"
theme.colors.pink      = "#f5c2e7"
theme.colors.mauve     = "#cba6f7"
theme.colors.red       = "#f38ba8"
theme.colors.maroon    = "#eba0ac"
theme.colors.peach     = "#fab387"
theme.colors.yellow    = "#f9e2af"
theme.colors.green     = "#a6e3a1"
theme.colors.teal      = "#94e2d5"
theme.colors.sky       = "#89dceb"
theme.colors.sapphire  = "#74c7ec"
theme.colors.blue      = "#89b4fa"
theme.colors.lavender  = "#b4befe"
theme.colors.text      = "#cdd6f4"
theme.colors.subtext1  = "#bac2de"
theme.colors.subtext0  = "#a6adc8"
theme.colors.overlay2  = "#9399b2"
theme.colors.overlay1  = "#7f849c"
theme.colors.overlay0  = "#6c7086"
theme.colors.surface2  = "#585b70"
theme.colors.surface1  = "#45475a"
theme.colors.surface0  = "#313244"
theme.colors.base      = "#1e1e2e"
theme.colors.mantle    = "#181825"
theme.colors.crust     = "#11111b"

theme.bg_normal     = theme.colors.surface0
theme.bg_focus      = theme.colors.mauve
theme.bg_urgent     = theme.colors.red
theme.bg_minimize   = theme.colors.mantle
theme.bg_systray    = theme.bg_normal

theme.fg_normal     = theme.colors.text
theme.fg_focus      = theme.colors.crust
theme.fg_urgent     = theme.colors.crust
theme.fg_minimize   = theme.colors.text

theme.useless_gap   = dpi(2)
theme.border_width  = dpi(2)
theme.border_normal = theme.colors.surface0
theme.border_focus  = theme.colors.mauve
theme.border_marked = theme.colors.red

-- There are other variable sets
-- overriding the default one when
-- defined, the sets are:
-- taglist_[bg|fg]_[focus|urgent|occupied|empty|volatile]
-- tasklist_[bg|fg]_[focus|urgent]
-- titlebar_[bg|fg]_[normal|focus]
-- tooltip_[font|opacity|fg_color|bg_color|border_width|border_color]
-- mouse_finder_[color|timeout|animate_timeout|radius|factor]
-- prompt_[fg|bg|fg_cursor|bg_cursor|font]
-- hotkeys_[bg|fg|border_width|border_color|shape|opacity|modifiers_fg|label_bg|label_fg|group_margin|font|description_font]
-- Example:
--theme.taglist_bg_focus = "#ff0000"

-- Generate taglist squares:
local taglist_square_size = dpi(4)
theme.taglist_squares_sel = theme_assets.taglist_squares_sel(
    taglist_square_size, theme.fg_normal
)
theme.taglist_squares_unsel = theme_assets.taglist_squares_unsel(
    taglist_square_size, theme.fg_normal
)

-- Notifications
theme.notification_bg = theme.colors.base
theme.notification_fg = theme.colors.text
theme.notification_border_width = theme.border_width
theme.notification_border_color = theme.border_focus

-- Hotkey menu
theme.hotkeys_bg = theme.colors.base
theme.hotkeys_fg = theme.colors.text
theme.hotkeys_modifiers_fg = theme.colors.subtext1
theme.hotkeys_border_color = theme.colors.mauve
theme.hotkeys_border_width = dpi(2)

-- Variables set for theming notifications:
-- notification_font
-- notification_[bg|fg]
-- notification_[width|height|margin]
-- notification_[border_color|border_width|shape|opacity]

-- Variables set for theming the menu:
-- menu_[bg|fg]_[normal|focus]
-- menu_[border_color|border_width]
theme.menu_submenu_icon = default_themes_path.."default/submenu.png"
theme.menu_height = dpi(15)
theme.menu_width  = dpi(150)

-- You can add as many variables as
-- you wish and access them by using
-- beautiful.variable in your rc.lua
--theme.bg_widget = "#cc0000"

-- Define the image to load
theme.titlebar_close_button_normal = default_themes_path.."default/titlebar/close_normal.png"
theme.titlebar_close_button_focus  = default_themes_path.."default/titlebar/close_focus.png"

theme.titlebar_minimize_button_normal = default_themes_path.."default/titlebar/minimize_normal.png"
theme.titlebar_minimize_button_focus  = default_themes_path.."default/titlebar/minimize_focus.png"

theme.titlebar_ontop_button_normal_inactive = default_themes_path.."default/titlebar/ontop_normal_inactive.png"
theme.titlebar_ontop_button_focus_inactive  = default_themes_path.."default/titlebar/ontop_focus_inactive.png"
theme.titlebar_ontop_button_normal_active = default_themes_path.."default/titlebar/ontop_normal_active.png"
theme.titlebar_ontop_button_focus_active  = default_themes_path.."default/titlebar/ontop_focus_active.png"

theme.titlebar_sticky_button_normal_inactive = default_themes_path.."default/titlebar/sticky_normal_inactive.png"
theme.titlebar_sticky_button_focus_inactive  = default_themes_path.."default/titlebar/sticky_focus_inactive.png"
theme.titlebar_sticky_button_normal_active = default_themes_path.."default/titlebar/sticky_normal_active.png"
theme.titlebar_sticky_button_focus_active  = default_themes_path.."default/titlebar/sticky_focus_active.png"

theme.titlebar_floating_button_normal_inactive = default_themes_path.."default/titlebar/floating_normal_inactive.png"
theme.titlebar_floating_button_focus_inactive  = default_themes_path.."default/titlebar/floating_focus_inactive.png"
theme.titlebar_floating_button_normal_active = default_themes_path.."default/titlebar/floating_normal_active.png"
theme.titlebar_floating_button_focus_active  = default_themes_path.."default/titlebar/floating_focus_active.png"

theme.titlebar_maximized_button_normal_inactive = default_themes_path.."default/titlebar/maximized_normal_inactive.png"
theme.titlebar_maximized_button_focus_inactive  = default_themes_path.."default/titlebar/maximized_focus_inactive.png"
theme.titlebar_maximized_button_normal_active = default_themes_path.."default/titlebar/maximized_normal_active.png"
theme.titlebar_maximized_button_focus_active  = default_themes_path.."default/titlebar/maximized_focus_active.png"

theme.wallpaper = theme_path .. "/background.png"


-- You can use your own layout icons like this:
theme.layout_fairh = default_themes_path.."default/layouts/fairhw.png"
theme.layout_fairv = default_themes_path.."default/layouts/fairvw.png"
theme.layout_floating  = default_themes_path.."default/layouts/floatingw.png"
theme.layout_magnifier = default_themes_path.."default/layouts/magnifierw.png"
theme.layout_max = default_themes_path.."default/layouts/maxw.png"
theme.layout_fullscreen = default_themes_path.."default/layouts/fullscreenw.png"
theme.layout_tilebottom = default_themes_path.."default/layouts/tilebottomw.png"
theme.layout_tileleft   = default_themes_path.."default/layouts/tileleftw.png"
theme.layout_tile = default_themes_path.."default/layouts/tilew.png"
theme.layout_tiletop = default_themes_path.."default/layouts/tiletopw.png"
theme.layout_spiral  = default_themes_path.."default/layouts/spiralw.png"
theme.layout_dwindle = default_themes_path.."default/layouts/dwindlew.png"
theme.layout_cornernw = default_themes_path.."default/layouts/cornernww.png"
theme.layout_cornerne = default_themes_path.."default/layouts/cornernew.png"
theme.layout_cornersw = default_themes_path.."default/layouts/cornersww.png"
theme.layout_cornerse = default_themes_path.."default/layouts/cornersew.png"

-- Generate Awesome icon:
theme.awesome_icon = theme_assets.awesome_icon(
    theme.menu_height, theme.bg_focus, theme.fg_focus
)

-- Define the icon theme for application icons. If not set then the icons
-- from /usr/share/icons and /usr/share/icons/hicolor will be used.
theme.icon_theme = nil

return theme

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
