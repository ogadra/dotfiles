{ pkgs, ... }:
{
  imports = [
    ./color.nix
    ./tab-bar.nix
    ./window.nix
    ./keybinds.nix
    ./background.nix
    ./render.nix
    ./focus.nix
  ];

  programs.wezterm = {
    enable = true;
    package = pkgs.wezterm;
    extraConfig = ''
      local wezterm = require 'wezterm'
      local color = require 'color'
      local tab_bar = require 'tab-bar'
      local window = require 'window'
      local keybinds = require 'keybinds'
      local background = require 'background'
      local render = require 'render'
      local focus = require 'focus'
      local config = {}

      color.apply_to_config(config, wezterm)
      tab_bar.apply_to_config(config, wezterm)
      window.apply_to_config(config, wezterm)
      keybinds.apply_to_config(config, wezterm)
      background.apply_to_config(config, wezterm)
      render.apply_to_config(config, wezterm)
      focus.apply_to_config(config, wezterm)

      return config
    '';
  };
}
