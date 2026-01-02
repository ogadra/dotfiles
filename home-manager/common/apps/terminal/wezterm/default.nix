{ inputs, pkgs, ... }:
{
  imports = [
    ./tab-bar.nix
  ];

  programs.wezterm = {
    enable = true;
    package = inputs.wezterm.packages.${pkgs.system}.default;
    extraConfig = ''
      local wezterm = require 'wezterm'
      local tab_bar = require 'tab-bar'
      local config = {}

      config.color_scheme = 'Ef-Elea-Dark'

      tab_bar.apply_to_config(config, wezterm)

      return config
    '';
  };
}
