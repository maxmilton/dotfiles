#!/bin/sh
# XDG_SESSION_TYPE=wayland exec dbus-run-session gnome-session
# XDG_SESSION_TYPE=wayland exec gnome-shell --wayland
# XDG_SESSION_TYPE=wayland exec gnome-session
XDG_SESSION_TYPE=wayland exec gnome-session --builtin
