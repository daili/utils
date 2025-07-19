#!/bin/bash

MODE="$1"  # Accept "on" or "off" as the first argument

SOCIAL_MEDIA_SITES=(
  "facebook.com" "www.facebook.com"
  "youtube.com" "www.youtube.com"
  "instagram.com" "www.instagram.com"
  "tiktok.com" "www.tiktok.com"
  "twitter.com" "www.twitter.com"
  "discord.com" "www.discord.com"
)

SHOPPING_SITES=(
  "amazon.com" "www.amazon.com"
  "ebay.com" "www.ebay.com"
  "aliexpress.com" "www.aliexpress.com"
  "walmart.com" "www.walmart.com"
  "etsy.com" "www.etsy.com"
  "shopify.com" "www.shopify.com"
  "myer.com.au" "www.myer.com.au"
  "davidjones.com" "www.davidjones.com"
  "kmart.com.au" "www.kmart.com.au"
  "target.com.au" "www.target.com.au"
  "temu.com" "www.temu.com"
  "muji.com" "www.muji.com"
  "mujistore.com.au" "www.mujistore.com.au"
)

OTHER_SITES=(
  "spotify.com" "www.spotify.com"
  "open.spotify.com"
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

# Combine all categories for blocking
BLOCKED_SITES=("${SOCIAL_MEDIA_SITES[@]}" "${SHOPPING_SITES[@]}" "${OTHER_SITES[@]}")

DISTRACTING_APPS=(
  "Messages"
  "FaceTime"
  "Steam"
  "Discord"
  "Spotify"
  "Roblox"
  "Google Chrome"
  "Minecraft"
)

HOUR=$(date +%H)
MIN=$(date +%M)
TARGET_USER="lidai"

if [ "$MODE" = "on" ]; then
  blocked_any=false
  for site in "${BLOCKED_SITES[@]}"; do
    if ! grep -E "^[^#]*127\.0\.0\.1[[:space:]]+$site" /etc/hosts > /dev/null; then
      echo "127.0.0.1 $site" >> /etc/hosts
      echo "[INFO] Blocked site: $site"
      blocked_any=true
    fi
  done

  quit_any=false
  for app in "${DISTRACTING_APPS[@]}"; do
    if [ "$app" = "Minecraft" ]; then
      if { [ "$HOUR" -lt 8 ] || [ "$HOUR" -gt 15 ] || { [ "$HOUR" -eq 15 ] && [ "$MIN" -ge 30 ]; }; }; then
        if pgrep -x "$app" > /dev/null; then
          pkill -x "$app"
          echo "[INFO] Killed app: $app (after school hours)"
          quit_any=true
        fi
      fi
    else
      if pgrep -x "$app" > /dev/null; then
        pkill -x "$app"
        echo "[INFO] Killed app: $app"
        quit_any=true
      fi
    fi
  done


elif [ "$MODE" = "off" ]; then
  cp /etc/hosts /etc/hosts.bak
  echo "[INFO] Backed up /etc/hosts to /etc/hosts.bak"
  for site in "${BLOCKED_SITES[@]}"; do
    if grep -E "^[^#]*127\.0\.0\.1[[:space:]]+$site" /etc/hosts > /dev/null; then
      sed -i '' "/^127\.0\.0\.1 $site/d" /etc/hosts
      echo "[INFO] Unblocked site: $site"
    fi
  done
  echo "Focus mode disabled."
else
  echo "Usage: $0 [on|off]"
fi
