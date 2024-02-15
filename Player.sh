#!/bin/bash
# A simple playerctl wrapper
# Author: KKV9

# Set your menu command here
MENU="rofi"
# Set album art status
ALBUM_ART=false
# Set album art path
ALBUM_ART_PATH=~/.cache/album-art.jpg
# Set menu prompt
PROMPT="PlayerControl"

# Exit if no media is playing
check=$(playerctl metadata)
if [ -z $check ]; then
	exit 0
fi

refresh() {
	# Remove old album art
	rm -f $ALBUM_ART_PATH

	if [ "$ALBUM_ART" = true ]; then
		# Get album art and trim it
		curl $(playerctl metadata --format "{{mpris:artUrl}}") >$ALBUM_ART_PATH && magick mogrify -define trim:percent-background=0% -trim +repage -format jpg $ALBUM_ART_PATH
	fi
}

# Set menu arguments
case $MENU in
"rofi")
	menu_args=(-dmenu -l 5 -p "$PROMPT")
	refresh
	;;
"fuzzel" | "wofi")
	menu_args=(-d -l 5 -p "$PROMPT")
	;;
"tofi")
	menu_args=(--prompt-text "$PROMPT")
	;;
"dmenu")
	menu_args=(-p "$PROMPT")
	;;
*)
	menu_args=()
	;;
esac

# Loop if option is selected
while true; do

	# Get currently playing
	current=$(playerctl metadata --format "{{artist}} - {{title}}")

	# Set menu options
	opts=("⏸️ $current" "⏭️ next track" "⏮️ previous track" "➡️ shift source forward" "⬅️ shift source backword")

	# Show play-pause status
	if [[ $(playerctl status) != "Playing" ]]; then
		opts[0]="▶️ $current"
	fi

	# Menu prompt
	selection=$(printf '%s\n' "${opts[@]}" | $MENU ${menu_args[@]})
	noRefresh=false

	# Handle selection
	case $selection in
	"${opts[0]}")
		playerctl play-pause
		noRefresh=true
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
	# Refresh album art if new song is playing
	if [ "$noRefresh" == false ]; then
		sleep 0.5
		refresh
	fi
done
