#!/bin/bash

MODE="$1"  # Accept "on" or "off" as the first argument

START_DATE="2024-07-22"
TODAY=$(date +%Y-%m-%d)

# Only run blocking logic if today is on or after 22 July 2024
if [[ "$TODAY" < "$START_DATE" ]]; then
  echo "Focus mode blocking will take effect from $START_DATE."
  exit 0
fi

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

if [ "$MODE" = "on" ]; then
  for site in "${BLOCKED_SITES[@]}"; do
    if ! grep -E "^[^#]*127\.0\.0\.1[[:space:]]+$site" /etc/hosts > /dev/null; then
      echo "127.0.0.1 $site" | tee -a /etc/hosts > /dev/null
    fi
  done
elif [ "$MODE" = "off" ]; then
  cp /etc/hosts /etc/hosts.bak
  for site in "${BLOCKED_SITES[@]}"; do
    sed -i '' "/127\.0\.0\.1[[:space:]]\+$site/d" /etc/hosts
  done
