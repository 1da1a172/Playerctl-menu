#!/bin/bash
# A simple playerctl wrapper
# Author: KKV9

# Set your menu command here
MENU="rofi"
# Set album art status
ALBUM_ART=true
# Set album art path
ALBUM_ART_PATH="$HOME/.cache/album-art.jpg"
# Set menu prompt
PROMPT="PlayerControl"
# Set the rofi config
ROFI_CONFIG="$HOME/.config/rofi/player.rasi"

# Exit if no media is playing
check=$(playerctl metadata)
if [[ -z $check ]]; then
	exit 0
fi

refresh() {
	# Remove old album art
	rm -f "${ALBUM_ART_PATH:?}"

	if [ "$ALBUM_ART" = true ] && [ "$MENU" = "rofi" ]; then
		sleep 0.2
		get_album_art | shape_album_art > "$ALBUM_ART_PATH"
	fi
}

get_album_art() {
	curl \
		--silent \
		--max-time 3 \
		"$(playerctl metadata mpris:artUrl)"
}

shape_album_art() {
	magick \
		/dev/stdin \
		-define trim:percent-background=0% \
		-trim \
		+repage \
		-resize 638x638! \
		/dev/stdout
}

is_playing() {
	[ "$(playerctl status)" = "Playing" ]
}

toggle_loop() {
	if [ "$(playerctl loop)" = "Playlist" ]; then
		playerctl loop Track
	elif [ "$(playerctl loop)" = "Track" ]; then
		playerctl loop None
	else
		playerctl loop Playlist
	fi
}

current() {
	playerctl \
		metadata \
		--format "{{artist}} - {{title}}"
}

menu() {
	prompt="${1:-$PROMPT}"
	case $MENU in
	"rofi")
		menuArgs=(-dmenu -l 7 -p "$prompt")
		if test -f "$ROFI_CONFIG"; then
			menuArgs+=(-config "$ROFI_CONFIG")
		fi
		refresh
		;;
	"fuzzel" | "wofi")
		menuArgs=(-d -l 7 -p "$prompt")
		;;
	"tofi")
		menuArgs=(--prompt-text "$prompt")
		;;
	"dmenu")
		menuArgs=(-p "$prompt")
		;;
	*)
		menuArgs=()
		;;
	esac
	$MENU "${menuArgs[@]}"
}

# Loop if option is selected
while true; do

	# Get currently playing
	current="$(current)"

	# Set menu options
	opts=(
		"1. ▶️ $current"
		"2. ⏭️ next track"
		"3. ⏮️ previous track"
		"4. ❌ loop"
		"5. ❌ shuffle"
		"6. ➡️ shift source forward"
		"7. ⬅️ shift source backward"
	)

	# Show play-pause status
	if is_playing; then
		opts[0]="1. ⏸️ $current"
	fi

	# Show loop status
	if [ "$(playerctl loop)" = "Playlist" ]; then
		opts[3]="4. 🔁 loop"
	elif [ "$(playerctl loop)" = "Track" ]; then
		opts[3]="4. 🔂 loop"
	fi

	# Show shuffle status
	if [ "$(playerctl shuffle)" = "On" ]; then
		opts[4]="5. 🔀 shuffle"
	fi

	# Menu prompt
	selection="$(printf '%s\n' "${opts[@]}" | menu)"
	noRefresh=false

	# Handle selection
	case "$selection" in
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
		toggle_loop
		noRefresh=true
		;;
	"${opts[4]}")
		playerctl shuffle toggle
		noRefresh=true
		;;
	"${opts[5]}")
		playerctld shift
		;;
	"${opts[6]}")
		playerctld unshift
		;;
	*)
		break
		;;
	esac
	# Refresh album art if new song is playing
	if [ "$noRefresh" = false ]; then
		refresh
	fi
done
