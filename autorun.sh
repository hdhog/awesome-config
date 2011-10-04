#!/bin/bash
sleep 5
kbdd &
mpd &
dbus-launch wicd-client&
parcellite &
#blueman-applet &
#nm-applet &
wmname LG3D &
