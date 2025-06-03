-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices.
-- For example, changing the initial geometry for new windows:
config.initial_cols = 100
config.initial_rows = 30

-- or, changing the font size and color scheme.
config.font_size = 11
-- config.color_scheme = 'Dimmed Monokai (Gogh)'
-- config.color_scheme = 'Doom Peacock'
-- config.color_scheme = 'Dracula+'
config.color_scheme = 'Vs Code Dark+ (Gogh)'
-- config.color_scheme = 'Monokai Dark (Gogh)'
-- config.color_scheme = 'MaterialDarker'
-- config.color_scheme = 'Materia (base16)'
-- config.color_scheme = 'Afterglow'

-- Finally, return the configuration to wezterm:
return config
