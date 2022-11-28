#!/bin/sh

run() {
    if ! pgrep -f "$1"; then
        "$@"&
    fi
}

dbus-update-activation-environment --all
gnome-keyring-daemon --start --components=secrets

nitrogen --restore

run gentoo-pipewire-launcher
run picom --experimental-backends
run nm-applet
run udiskie -t
