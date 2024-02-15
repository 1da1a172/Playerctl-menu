# Playerctl-menu

## Description

A simple playerctl wrapper for dmenu

## Screenshots

![Alt text](example-fuzzel.png?raw=true "Example Fuzzel menu")

## Features

- Show the current playing song
- Play/Pause
- Next/Previous
- Change player (if multiple players are running)

## Usage

- Clone the repository
- Open the script and change the menu to your preferred one
- Compatible with rofi, dmenu, fuzzel, etc.

## Expermiental features

### Rofi album art

- Requires `imagemagick` and `curl`
- Set the `ALBUM_ART` variable in the script to true
- Add the following to your `~/.config/rofi/config` file

```css
window {
  width: 750px;
  height: 400px;
  background-image: url("~/.cache/album-art.jpg", width);
}
```
