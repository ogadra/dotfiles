{ pkgs, ... }:
let
  emacsPackage =
    if pkgs.stdenv.hostPlatform.isLinux
    then pkgs.emacs-pgtk
    else pkgs.emacs-macport;
in
{
  programs.emacs = {
    enable = true;
    package = emacsPackage;
    extraPackages = epkgs: with epkgs; [
      use-package

      vertico
      marginalia
      orderless
      consult
      embark
      embark-consult

      corfu
      cape

      magit

      terraform-mode

      (treesit-grammars.with-grammars (gs: with gs; [
        tree-sitter-go
        tree-sitter-typescript
        tree-sitter-javascript
        tree-sitter-hcl
      ]))

      org
      org-modern

      markdown-mode

      dirvish

      doom-themes
      doom-modeline
      nerd-icons

      which-key
      rainbow-delimiters
    ];
  };

  xdg.configFile."emacs/init.el".source = ./init.el;

  services.emacs = {
    enable = true;
    defaultEditor = true;
  };

  programs.fish.interactiveShellInit = ''
    function emacs
      if contains -- --gui $argv
        set -l args (string match -v -- "--gui" $argv)
        emacsclient -c -n -a "" $args
      else
        emacsclient -t -a "" $argv
      end
    end
  '';
}
