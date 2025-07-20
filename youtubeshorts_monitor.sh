#!/bin/bash

LOGFILE="/tmp/youtube_shorts_guard.log"
exec > >(while read line; do echo "$(date '+[%Y-%m-%d %H:%M:%S]') $line"; done >> "$LOGFILE") 2>&1

WARN_COUNT_FILE="/tmp/youtube_shorts_warn_count"
MARKER_FILE="/tmp/youtube_shorts_blocked"
WARN_LIMIT=3

HOUR=$(date +%H)
MIN=$(date +%M)
DAY=$(date +%u) # 1=Monday ... 5=Friday

is_school_hours() {
  [ "$DAY" -ge 1 ] && [ "$DAY" -le 5 ] && \
  { [ "$HOUR" -gt 8 ] || { [ "$HOUR" -eq 8 ] && [ "$MIN" -ge 15 ]; }; } && \
  { [ "$HOUR" -lt 15 ] || { [ "$HOUR" -eq 15 ] && [ "$MIN" -le 15 ]; }; }
}


check_safari_shorts() {
  SAFARI_HISTORY="$HOME/Library/Safari/History.db"
  if [ -f "$SAFARI_HISTORY" ]; then
    sqlite3 "$SAFARI_HISTORY" "SELECT url FROM history_items WHERE url LIKE '%youtube.com/shorts%'" | grep -q "youtube.com/shorts"
  else
    return 1
  fi
}

if is_school_hours; then
  if check_safari_shorts; then
    WARN_COUNT=0
    if [ -f "$WARN_COUNT_FILE" ]; then
      WARN_COUNT=$(cat "$WARN_COUNT_FILE")
    fi
    WARN_COUNT=$((WARN_COUNT + 1))
    echo "$WARN_COUNT" > "$WARN_COUNT_FILE"

    if [ "$WARN_COUNT" -ge "$WARN_LIMIT" ]; then
      touch "$MARKER_FILE"
      echo "[WARNING] YouTube Shorts marker file created: $MARKER_FILE"
    else
      osascript -e 'display dialog "Warning: YouTube Shorts visited in Safari during school hours!" buttons {"OK"} with icon caution'
      echo "[WARNING] YouTube Shorts visited in Safari during school hours! Warning $WARN_COUNT/$WARN_LIMIT"
    fi
  else
    echo "0" > "$WARN_COUNT_FILE"
    echo "[INFO] No YouTube Shorts visited in Safari during school hours. Warning count reset."
  fi
else
  echo "[INFO] Not school hours. No check performed."
fi