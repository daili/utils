

YOUTUBE_SITES=("youtube.com" "www.youtube.com")
MARKER_FILE="/tmp/youtube_shorts_blocked"

is_school_hours() {
  DAY=$(date +%u) # 1=Monday ... 5=Friday
  [ "$DAY" -ge 1 ] && [ "$DAY" -le 5 ] && [ "$HOUR" -ge 8 ] && { [ "$HOUR" -lt 15 ] || { [ "$HOUR" -eq 15 ] && [ "$MIN" -lt 30 ]; }; }
}


blocked_any=false

if is_school_hours; then
  # During school hours, unblock YouTube if marker is not present
  if [ ! -f "$MARKER_FILE" ]; then
    for site in "${YOUTUBE_SITES[@]}"; do
      if grep -E "^[^#]*127\.0\.0\.1[[:space:]]+$site" /etc/hosts > /dev/null; then
        sudo sed -i '' "/127\.0\.0\.1[[:space:]]\+$site/d" /etc/hosts
        echo "[INFO] Unblocked YouTube during school hours: $site"
      fi
    done
  fi
else
  # Non-school hours: always block YouTube
  for site in "${YOUTUBE_SITES[@]}"; do
    if ! grep -E "^[^#]*127\.0\.0\.1[[:space:]]+$site" /etc/hosts > /dev/null; then
      echo "127.0.0.1 $site" | sudo tee -a /etc/hosts > /dev/null
      echo "[INFO] Blocked YouTube (non-school hours): $site"
    fi
  done
fi

