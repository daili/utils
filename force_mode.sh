#!/bin/bash

MODE="$1"  # Accept "on" or "off" as the first argument

BLOCKED_SITES=(
"facebook.com" "www.facebook.com"
"youtube.com" "www.youtube.com"
"instagram.com" "www.instagram.com"
"tiktok.com" "www.tiktok.com"
"twitter.com" "www.twitter.com"
"amazon.com" "www.amazon.com"
"ebay.com" "www.ebay.com"
"aliexpress.com" "www.aliexpress.com"
"walmart.com" "www.walmart.com"
"etsy.com" "www.etsy.com"
"shopify.com" "www.shopify.com"
"discord.com" "www.discord.com"
"spotify.com" "www.spotify.com"
"open.spotify.com"
"myer.com.au" "www.myer.com.au"
"davidjones.com" "www.davidjones.com"
"kmart.com.au" "www.kmart.com.au"
"target.com.au" "www.target.com.au"
"temu.com" "www.temu.com"
"muji.com" "www.muji.com"
"mujistore.com.au" "www.mujistore.com.au"
"netflix.com" "www.netflix.com"
"stan.com.au" "www.stan.com.au"
"primevideo.com" "www.primevideo.com"
"primevideo.com.au" "www.primevideo.com.au"
"disneyplus.com" "www.disneyplus.com"
"binge.com.au" "www.binge.com.au"
"hulu.com" "www.hulu.com"
"tv.apple.com"
"9now.com.au" "www.9now.com.au"
"7plus.com.au" "www.7plus.com.au"
"iview.abc.net.au"
"dailymotion.com" "www.dailymotion.com"
"twitch.tv" "www.twitch.tv"
"vimeo.com" "www.vimeo.com"
"aigua.tv" "www.aigua.tv"
)

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

if [ "$MODE" = "on" ]; then
  blocked_any=false
  for site in "${BLOCKED_SITES[@]}"; do
    if ! grep -E "^[^#]*127\.0\.0\.1[[:space:]]+$site" /etc/hosts > /dev/null; then
      echo "127.0.0.1 $site" | sudo tee -a /etc/hosts > /dev/null
      blocked_any=true
    fi
  done

  quit_any=false
  for app in "${DISTRACTING_APPS[@]}"; do
    # Only quit Minecraft after school hours
    if [ "$app" = "Minecraft" ]; then
      if { [ "$HOUR" -lt 8 ] || [ "$HOUR" -gt 15 ] || { [ "$HOUR" -eq 15 ] && [ "$MIN" -ge 30 ]; }; }; then
        if pgrep -x "$app" > /dev/null; then
          osascript -e "tell application \"$app\" to quit" 2>/dev/null
          quit_any=true
        fi
      fi
    else
      if pgrep -x "$app" > /dev/null; then
        osascript -e "tell application \"$app\" to quit" 2>/dev/null
        quit_any=true
      fi
    fi
  done

  # Only enable or disable Do Not Disturb based on school hours
  dnd_enabled=false
  if { [ "$HOUR" -lt 8 ] || [ "$HOUR" -gt 15 ] || { [ "$HOUR" -eq 15 ] && [ "$MIN" -ge 30 ]; }; }; then
    # After school hours: turn on Do Not Disturb if not already enabled
    if ! defaults -currentHost read ~/Library/Preferences/ByHost/com.apple.notificationcenterui doNotDisturb 2>/dev/null | grep -q "1"; then
      defaults -currentHost write ~/Library/Preferences/ByHost/com.apple.notificationcenterui doNotDisturb -boolean true
      dnd_enabled=true
    fi
  else
    # During school hours: turn off Do Not Disturb if enabled
    if defaults -currentHost read ~/Library/Preferences/ByHost/com.apple.notificationcenterui doNotDisturb 2>/dev/null | grep -q "1"; then
      defaults -currentHost write ~/Library/Preferences/ByHost/com.apple.notificationcenterui doNotDisturb -boolean false
    fi
  fi

  if $blocked_any || $quit_any || $dnd_enabled; then
    osascript -e 'display dialog "Stay focused and do your best work!" buttons {"OK"} with icon note'
  fi

elif [ "$MODE" = "off" ]; then
  # Remove blocked sites from /etc/hosts
  sudo cp /etc/hosts /etc/hosts.bak
  for site in "${BLOCKED_SITES[@]}"; do
    sudo sed -i '' "/127\.0\.0\.1[[:space:]]\+$site/d" /etc/hosts
  done
  # Disable Do Not Disturb
  defaults -currentHost write ~/Library/Preferences/ByHost/com.apple.notificationcenterui doNotDisturb -boolean false
  echo "Focus mode disabled."
else
  echo "Usage: $0 [on|off]"
fi
