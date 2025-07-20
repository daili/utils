YOUTUBE_SITES=("youtube.com" "www.youtube.com")
MARKER_FILE="/tmp/youtube_shorts_blocked"
LOGFILE="/tmp/youtube_shorts_guard.log"

DAY=$(date +%u)
HOUR=$(date +%H)
MIN=$(date +%M)

exec > >(while read line; do echo "$(date '+[%Y-%m-%d %H:%M:%S]') $line"; done >> "$LOGFILE") 2>&1

is_school_hours() {
  [ "$DAY" -ge 1 ] && [ "$DAY" -le 5 ] && \
  { [ "$HOUR" -gt 8 ] || { [ "$HOUR" -eq 8 ] && [ "$MIN" -ge 15 ]; }; } && \
  { [ "$HOUR" -lt 15 ] || { [ "$HOUR" -eq 15 ] && [ "$MIN" -le 15 ]; }; }
}

blocked_any=false

if is_school_hours; then
  # During school hours, check marker
  if [ -f "$MARKER_FILE" ]; then
    for site in "${YOUTUBE_SITES[@]}"; do
      if ! grep -E "^[^#]*127\.0\.0\.1[[:space:]]+$site" /etc/hosts > /dev/null; then
        echo "127.0.0.1 $site" | sudo tee -a /etc/hosts > /dev/null
        echo "[WARNING] Blocked YouTube during school hours due to marker: $site"
      fi
    done
  else
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