#!/bin/sh

dbus-update-activation-environment --all
gnome-keyring-daemon --start --components=secrets

nitrogen --restore

gentoo-pipewire-launcher &
picom --experimental-backends &
nm-applet &
udiskie -t &
