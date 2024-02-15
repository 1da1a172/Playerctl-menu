# Playerctl-menu

## Description

A simple playerctl wrapper for rofi/dmenu

## Screenshots

![Alt text](example-fuzzel.png?raw=true "Example Fuzzel menu")

## Features

- Show the current playing song
- Play/Pause
- Next/Previous
- loop, shuffle, repeat
- Change player (if multiple players are running)
- Album art (rofi only)

## Usage

- Requires `playerctl` and your menu of choice
- Clone the repository
- Open the script and change the menu to your preferred one
- Compatible with rofi, dmenu, fuzzel, etc.
- Play some music and run the script

## Rofi album art

- Requires `imagemagick` and `curl`
- Through the `window` class you can set the background image to the album art
- Window width should be at least 700px
- You may copy the following to your `~/.config/rofi/config.rasi` file as an example

```css
window {
  width: 725px;
  height: 420px;
  background-image: url("~/.cache/album-art.jpg", width);
}
```
