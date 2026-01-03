{ inputs, pkgs, ... }:
{
  imports = [
    ./color.nix
    ./tab-bar.nix
    ./window.nix
  ];

  programs.wezterm = {
    enable = true;
    package = inputs.wezterm.packages.${pkgs.system}.default;
    extraConfig = ''
      local wezterm = require 'wezterm'
      local color = require 'color'
      local tab_bar = require 'tab-bar'
      local window = require 'window'
      local config = {}

      color.apply_to_config(config, wezterm)
      tab_bar.apply_to_config(config, wezterm)
      window.apply_to_config(config, wezterm)

      return config
    '';
  };
}
