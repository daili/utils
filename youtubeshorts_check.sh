#!/bin/bash

# Path to Safari history database
HISTORY_DB="$HOME/Library/Safari/History.db"

# Current time and 3 minutes ago in Apple Epoch (Jan 1, 2001)
NOW=$(date +%s)
FIVE_MIN_AGO=$((NOW - 180))                    # 180 seconds = 3 minutes
APPLE_EPOCH=978307200
START_TIME=$((FIVE_MIN_AGO - APPLE_EPOCH))
END_TIME=$((NOW - APPLE_EPOCH))

# Query Safari history for YouTube Shorts in the past 5 minutes
FOUND=$(sqlite3 "$HISTORY_DB" "
SELECT url
FROM history_visits
JOIN history_items ON history_items.id = history_visits.history_item
WHERE url LIKE '%youtube.com/shorts%'
AND visit_time BETWEEN $START_TIME AND $END_TIME;
")

# If any Shorts found, show alert
if [[ -n "$FOUND" ]]; then
    echo "youtubeshortviolation" >> /tmp/.youtube.violation.log
    osascript -e 'display alert "Warning" message "YouTube Shorts were visited in the past 3 minutes! If you continue watching, YouTube will be banned!" as critical'
else
    echo "No YouTube Shorts visited in the past 3 minutes."
fi

