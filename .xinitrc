#!/bin/sh

# Remap caps to escape
setxkbmap -option caps:escape

# Launch PipeWire
gentoo-pipewire-launcher &

# Launch awesome
exec dbus-launch awesome
