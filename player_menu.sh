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
# Set menu prompt for picking a player
PLAYER_PROMPT="${PROMPT}"
# Set the rofi config
ROFI_CONFIG="$HOME/.config/rofi/player.rasi"

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
		"$(playerctl --player "$PLAYER" metadata mpris:artUrl)"
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
	[ "$(playerctl --player "${1:-$PLAYER}" status)" = "Playing" ]
}

toggle_loop() {
	if [ "$(playerctl --player "$PLAYER" loop)" = "Playlist" ]; then
		playerctl loop Track
	elif [ "$(playerctl --player "$PLAYER" loop)" = "Track" ]; then
		playerctl loop None
	else
		playerctl loop Playlist
	fi
}

current() {
	playerctl \
		--player "$PLAYER" \
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

select_player() {
	# Build list of players to choose from
	playerList=()
	while read -r somePlayer; do
		if is_playing "$somePlayer"; then
			playerList+=("$somePlayer")
		fi
	done < <(playerctl --list-all)
	if [ ${#playerList[@]} = 0 ]; then
		mapfile -t playerList < <(playerctl --list-all)
	fi

	# Only display a menu for multiple options
	case ${#playerList[@]} in
	0)
		return 1
		;;
	1)
		printf '%s' "${playerList[0]}"
		return 0
		;;
	esac

	# Build menu options
	opts=()
	for somePlayer in "${playerList[@]}"; do
		opts+=("$(printf '%d. %s | %s' \
			$(( ${#opts[@]} + 1 )) \
			"$somePlayer" \
			"$(current "$somePlayer")"
		)")
	done

	# Pick a player
	selected="$(printf '%s\n' "${opts[@]}" \
		| menu "$PLAYER_PROMPT" \
		| cut -f 1 -d .
	)"
	[ -z "$selected" ] && exit 1
	(( selected-- ))
	printf '%s' "${playerList[$selected]}"
}

PLAYER="$(select_player)" || exit 0

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
	if [ "$(playerctl --player "$PLAYER" loop)" = "Playlist" ]; then
		opts[3]="4. 🔁 loop"
	elif [ "$(playerctl --player "$PLAYER" loop)" = "Track" ]; then
		opts[3]="4. 🔂 loop"
	fi

	# Show shuffle status
	if [ "$(playerctl --player "$PLAYER" shuffle)" = "On" ]; then
		opts[4]="5. 🔀 shuffle"
	fi

	# Menu prompt
	selection="$(printf '%s\n' "${opts[@]}" | menu)"
	noRefresh=false

	# Handle selection
	case "$selection" in
	"${opts[0]}")
		playerctl --player "$PLAYER" play-pause
		noRefresh=true
		;;
	"${opts[1]}")
		playerctl --player "$PLAYER" next
		;;
	"${opts[2]}")
		playerctl --player "$PLAYER" previous
		;;
	"${opts[3]}")
		toggle_loop
		noRefresh=true
		;;
	"${opts[4]}")
		playerctl --player "$PLAYER" shuffle toggle
		noRefresh=true
		;;
	"${opts[5]}")
		playerctl --player "$PLAYER" shift
		;;
	"${opts[6]}")
		playerctl --player "$PLAYER" unshift
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
