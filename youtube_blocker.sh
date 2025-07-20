#!/bin/bash

LOG_FILE="/tmp/.youtube.violation.log"
BLOCK_MARKER="# youtube.com block added by script"
HOSTS_FILE="/etc/hosts"

# Count occurrences of 'youtubeshortviolation' (case insensitive)
COUNT=$(grep -i -c "youtubeshortviolation" "$LOG_FILE" 2>/dev/null || echo 0)
COUNT=${COUNT:-0}
if ! [[ "$COUNT" =~ ^[0-9]+$ ]]; then
    COUNT=0
fi

if (( COUNT >= 3 )); then
    # Check if hosts already contains block marker
    if ! grep -qF "$BLOCK_MARKER" "$HOSTS_FILE"; then
        echo "Blocking YouTube as violation count is $COUNT..."

        {
            echo ""
            echo "$BLOCK_MARKER"
            echo "127.0.0.1 youtube.com"
            echo "127.0.0.1 www.youtube.com"
        } | sudo tee -a "$HOSTS_FILE" > /dev/null

        echo "YouTube is now blocked."

        # Clean up the violation log file
        > "$LOG_FILE"
        echo "Violation log file cleared."
    else
        echo "YouTube is already blocked."
    fi
else
    echo "Violation count ($COUNT) less than 3. No action taken."
fi
