systemctl --user import-environment DISPLAY XAUTHORITY

if which dbus-update-activation-environment >/dev/null 2>&1; then
	dbus-update-activation-environment DISPLAY XAUTHORITY
fi

xinput --set-prop 'DELL0A20:00 06CB:CE65 Touchpad' 'libinput Tapping Enabled'                      1
xinput --set-prop 'DELL0A20:00 06CB:CE65 Touchpad' 'libinput Tapping Drag Enabled'                 1
xinput --set-prop 'DELL0A20:00 06CB:CE65 Touchpad' 'libinput Tapping Drag Lock Enabled'            0
xinput --set-prop 'DELL0A20:00 06CB:CE65 Touchpad' 'libinput Natural Scrolling Enabled'            1
xinput --set-prop 'DELL0A20:00 06CB:CE65 Touchpad' 'libinput Disable While Typing Enabled'         1
xinput --set-prop 'DELL0A20:00 06CB:CE65 Touchpad' 'libinput Horizontal Scroll Enabled'            1

xrdb ~/.Xresources
exec dbus-launch i3
