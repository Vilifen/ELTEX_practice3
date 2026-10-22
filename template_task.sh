#!/bin/bash

SCRIPT_NAME=$(basename "$0")

if [ "$SCRIPT_NAME" = "template_task.sh" ]; then
    echo "я бригадир, сам не работаю"
    exit 0
fi

LOG_FILE="report_${SCRIPT_NAME}.log"
echo "$(date '+%Y-%m-%d %H:%M:%S') [$$] Скрипт запущен" >> "$LOG_FILE"

CUCKOO_PIPE=""
for pid in $(pgrep -f "cuckoo.sh"); do
    if [ -e "/proc/$pid/cmdline" ]; then
        CUCKOO_PIPE=$(tr '\0' ' ' < "/proc/$pid/cmdline" | grep -oP '(?<=--pishitesuda=)\S+')
        if [ -n "$CUCKOO_PIPE" ] && [ -p "$CUCKOO_PIPE" ]; then
            break
        fi
    fi
done

if [ -z "$CUCKOO_PIPE" ] || [ ! -p "$CUCKOO_PIPE" ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') [$$] Ошибка: канал cuckoo.sh не найден" >> "$LOG_FILE"
    exit 1
fi

RESP_PIPE="${CUCKOO_PIPE}_resp"

echo "$SCRIPT_NAME[$$]: how much time do I have?" > "$CUCKOO_PIPE"

read -r N < "$RESP_PIPE"

if ! [[ "$N" =~ ^[0-9]+$ ]]; then
    N=5
fi

sleep "$N"

echo "$(date '+%Y-%m-%d %H:%M:%S') [$$] Скрипт завершился, работал $N секунд." >> "$LOG_FILE"
