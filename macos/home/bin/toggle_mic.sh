#!/usr/bin/env bash

# Get current input volume
cur=$(osascript -e "input volume of (get volume settings)")

if [[ ${cur} -eq 0 ]]; then
    # Mic is “muted” (volume = 0) → unmute
    osascript -e "set volume input volume 100"
    osascript -e 'display notification "You are now unmuted" with title "Mic Status"'
else
    # Muted
    osascript -e "set volume input volume 0"
    osascript -e 'display notification "You are now muted" with title "Mic Status"'
fi
