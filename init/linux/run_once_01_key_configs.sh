#!/bin/bash

# Emacs keybindings for GTK apps, which need a logout to take effect; see https://linuxfan.info/emacs-key-theme
gsettings set org.gnome.desktop.interface gtk-key-theme 'Emacs'

# https://github.com/xremap/xremap
cargo install xremap --features x11

systemctl --user start xremap.service
systemctl --user enable xremap.service
