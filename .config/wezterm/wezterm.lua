-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This table will hold the configuration.
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
	config = wezterm.config_builder()
end

-- Spawn a fish shell in login mode
config.default_prog = { "/usr/bin/fish", "-l" }
config.default_cursor_style = "BlinkingBlock"
config.cursor_blink_rate = 500
config.animation_fps = 1
config.cursor_blink_ease_in = "Constant"
config.cursor_blink_ease_out = "Constant"

config.background = {
	{
		source = {
			File = ".terminal_wallpapers/anime/aot_mikasa.png",
		},
		opacity = 0.01,
	},
}

-- Set background to same color as neovim
-- config.colors = {}
-- config.colors.background = "#15161e"

-- This is where you actually apply your config choices

-- For example, changing the color scheme:
-- config.font = wezterm.font("Hack Nerd Font")
-- config.color_scheme = "AdventureTime"
config.window_padding = {
	left = 0,
	right = 0,
	top = 0,
	bottom = 0,
}
config.hide_tab_bar_if_only_one_tab = true
config.initial_rows = 50
config.initial_cols = 160
-- When using disable_default_key_bindings, it is recommended that you assign
-- ShowDebugOverlay to something to aid in potential future troubleshooting.
-- Likewise, you may wish to assign ActivateCommandPalette.
config.disable_default_key_bindings = true
config.adjust_window_size_when_changing_font_size = false
config.keys = {
	{
		key = "V",
		mods = "CTRL",
		action = wezterm.action.PasteFrom("Clipboard"),
	},
	{
		key = "=",
		mods = "CTRL",
		action = wezterm.action.IncreaseFontSize,
	},
	{
		key = "-",
		mods = "CTRL",
		action = wezterm.action.DecreaseFontSize,
	},
	{
		key = "0",
		mods = "CTRL",
		action = wezterm.action.ResetFontSize,
	},
}

-- and finally, return the configuration to wezterm
return config
