YOUTUBE_SITES=("youtube.com" "www.youtube.com")
MARKER_FILE="/tmp/youtube_shorts_blocked"
LOGFILE="/tmp/youtube_shorts_guard.log"

DAY=$(date +%u)
HOUR=$(date +%H)
MIN=$(date +%M)

exec > >(while read line; do echo "$(date '+[%Y-%m-%d %H:%M:%S]') $line"; done >> "$LOGFILE") 2>&1



# School hours: Mon-Fri, 08:30 to 15:30
is_school_hours() {
  [ "$DAY" -ge 1 ] && [ "$DAY" -le 5 ] && \
  { [ "$HOUR" -gt 8 ] || { [ "$HOUR" -eq 8 ] && [ "$MIN" -ge 30 ]; }; } && \
  { [ "$HOUR" -lt 15 ] || { [ "$HOUR" -eq 15 ] && [ "$MIN" -le 30 ]; }; }
}

if is_school_hours; then
  # During school hours: unblock YouTube
  for site in "${YOUTUBE_SITES[@]}"; do
    if grep -E "^[^#]*127\.0\.0\.1[[:space:]]+$site" /etc/hosts > /dev/null; then
      sed -i '' "/^127\.0\.0\.1 $site/d" /etc/hosts
      echo "[INFO] Unblocked YouTube during school hours: $site"
    fi
  done
else
  # Non-school hours: block YouTube
  for site in "${YOUTUBE_SITES[@]}"; do
    if ! grep -E "^[^#]*127\.0\.0\.1[[:space:]]+$site" /etc/hosts > /dev/null; then
      echo "127.0.0.1 $site" | tee -a /etc/hosts > /dev/null
      echo "[INFO] Blocked YouTube (non-school hours): $site"
    fi
  done
fi
