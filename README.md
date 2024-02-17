# Playerctl-menu

## Description

A simple playerctl wrapper for rofi/dmenu

## Features

- Show the current playing song
- Play/Pause
- Next/Previous
- loop, shuffle, repeat
- Change player (if multiple players are running)
- Album art (rofi only)

## Screenshots

![Alt text](example-fuzzel.png?raw=true "Example Fuzzel menu")

## Usage

- Requires `playerctl` and your menu of choice
- Clone the repository
- Open the script and change the menu to your preferred one
- Compatible with rofi, dmenu, fuzzel, etc.
- Play some music and run the script

## Rofi album art

- Requires `imagemagick` and `curl`
- Clone the repository and run the following command

```bash
cd Playerctl-menu/ && cp player.rasi ~/.config/rofi/player.rasi
```

- Modify the `player.rasi` file to your liking
- Use the `playerctl-menu` script as usual
