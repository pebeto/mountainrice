#!/bin/bash
if [ "$(setxkbmap -print -verbose | grep "xkb_symbols" | awk '{print$4;}')" = "\"pc+latam(dvorak)+inet(evdev)\"" ]; then
		setxkbmap latam
else
		setxkbmap -layout latam -variant dvorak
fi
