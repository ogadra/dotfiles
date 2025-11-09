local wezterm = require 'wezterm'

local module = {}

function module.apply_to_config(config)
    config.color_scheme = 'Material Darker (base16)'
end

return module
