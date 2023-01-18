#!/bin/sh

# Remap caps to escape
setxkbmap -option caps:escape

# Launch awesome
exec dbus-launch --exit-with-session awesome
