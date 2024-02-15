#!/bin/bash
# A simple playerctl wrapper
# Author: KKV9

# Set your menu command here
MENU="rofi"
# Set menu prompt
PROMPT="PlayerControl"

# Set menu command arguments
if [[ $MENU == "rofi" ]]; then
	menu_args=(-dmenu -l 5 -p "$PROMPT")
elif [[ $MENU == "fuzzel" || $MENU == "wofi" ]]; then
	menu_args=(-d -l 5 -p "$PROMPT")
elif [[ $MENU == "tofi" ]]; then
	menu_args=(--prompt-text "$PROMPT")
elif [[ $MENU == "dmenu" ]]; then
	menu_args=(-p "$PROMPT")
else
	menu_args=()
fi

# Exit if no media is playing
check=$(playerctl metadata)
if [ -z $check ]; then
	exit 0
fi

# Loop if option is selected
while true; do
	# Get currently playing
	current=$(playerctl metadata --format "{{artist}} - {{title}}")
	# Set menu options
	opts=("⏸️ $current" "⏭️ next track" "⏮️ previous track" "➡️ shift source forward" "⬅️ shift source backword")
	# Toggle pause/play
	if [[ $(playerctl status) != "Playing" ]]; then
		opts[0]="▶️ $current"
	fi
	# Menu prompt
	selection=$(printf '%s\n' "${opts[@]}" | $MENU ${menu_args[@]})
	case $selection in
	"${opts[0]}")
		playerctl play-pause
		;;
	"${opts[1]}")
		playerctl next
		;;
	"${opts[2]}")
		playerctl previous
		;;
	"${opts[3]}")
		playerctld shift
		;;
	"${opts[4]}")
		playerctld unshift
		;;
	*)
		break
		;;
	esac
done
