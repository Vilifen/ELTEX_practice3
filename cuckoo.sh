#!/bin/bash

PIPE_REQ=""
LOG_FILE="/root/practice3/cuckoo.log"

for arg in "$@"; do
    case "$arg" in
        --pishitesuda=*)
            PIPE_REQ="${arg#--pishitesuda=}"
            ;;
    esac
done

if [ -z "$PIPE_REQ" ]; then
    echo "Usage: $0 --pishitesuda=/abs/path/to/pipe"
    exit 1
fi

PIPE_RESP="${PIPE_REQ}_resp"

cleanup() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') Shutdown!" >> "$LOG_FILE"
    rm -f "$PIPE_REQ" "$PIPE_RESP"
    exit 0
}

trap cleanup SIGTERM SIGINT

mkdir -p "$(dirname "$PIPE_REQ")"
rm -f "$PIPE_REQ" "$PIPE_RESP"
mkfifo "$PIPE_REQ"
mkfifo "$PIPE_RESP"

echo "$(date '+%Y-%m-%d %H:%M:%S') Startup!" >> "$LOG_FILE"

exec 3<> "$PIPE_REQ"

while true; do
    if read -r line <&3; then
        if [[ "$line" =~ ^([A-Za-z0-9_.-]+)\[([0-9]+)\]:\ how\ much\ time\ do\ I\ have\?$ ]]; then
            name="${BASH_REMATCH[1]}"
            pid="${BASH_REMATCH[2]}"
            n=$((RANDOM % 9 + 2))
            
            echo "$(date '+%Y-%m-%d %H:%M:%S') ${name}[${pid}] $n" >> "$LOG_FILE"
            
            echo "$n" > "$PIPE_RESP"
        fi
    fi
done
