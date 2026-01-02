{ inputs, pkgs, ... }:
{
  programs.wezterm = {
    enable = true;
    package = inputs.wezterm.packages.${pkgs.system}.default;
    extraConfig = ''
      local config = {}
      config.color_scheme = 'Ef-Elea-Dark'
      return config
    '';
  };
}
