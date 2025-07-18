#!/bin/bash

DISTRACTING_APPS=(
  "Messages"
  "FaceTime"
  "Steam"
  "Discord"
  "Spotify"
  "Roblox"
  "Google Chrome"
)

HOUR=$(date +%H)
MIN=$(date +%M)

for app in "${DISTRACTING_APPS[@]}"; do
  if [ "$app" = "Minecraft" ]; then
    if { [ "$HOUR" -lt 8 ] || [ "$HOUR" -gt 15 ] || { [ "$HOUR" -eq 15 ] && [ "$MIN" -ge 30 ]; }; }; then
      if pgrep -x "$app" > /dev/null; then
        osascript -e "tell application \"$app\" to quit" 2>/dev/null
      fi
    fi
  else
    if pgrep -x "$app" > /dev/null; then
      osascript -e "tell application \"$app\" to quit" 2>/dev/null
    fi
  fi
done

if { [ "$HOUR" -lt 8 ] || [ "$HOUR" -gt 15 ] || { [ "$HOUR" -eq 15 ] && [ "$MIN" -ge 30 ]; }; }; then
  defaults -currentHost write ~/Library/Preferences/ByHost/com.apple.notificationcenterui doNotDisturb -boolean true
else
  defaults -currentHost write ~/Library/Preferences/ByHost/com.apple.notificationcenterui doNotDisturb -boolean false
fi
