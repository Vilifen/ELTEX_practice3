#!/bin/bash

SCRIPT_NAME=$(basename "$0")

if [ "$SCRIPT_NAME" = "template_task.sh" ]; then
    echo "я бригадир, сам не работаю"
    exit 0
fi

LOG_FILE="report_${SCRIPT_NAME%.sh}.log"
echo "$(date '+%Y-%m-%d %H:%M:%S') [$$] Скрипт запущен" >> "$LOG_FILE"

CUCKOO_PIPE=""
for cmdline in /proc/[0-9]*/cmdline; do
    if tr '\0' ' ' < "$cmdline" 2>/dev/null | grep -q "cuckoo.sh --pishitesuda="; then
        CUCKOO_PIPE=$(tr '\0' ' ' < "$cmdline" | sed -n 's/.*--pishitesuda=\([^ ]*\).*/\1/p')
        if [ -n "$CUCKOO_PIPE" ] && [ -p "$CUCKOO_PIPE" ]; then
            break
        fi
    fi
done

if [ -z "$CUCKOO_PIPE" ] || [ ! -p "$CUCKOO_PIPE" ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') [$$] Ошибка: канал cuckoo.sh не найден" >> "$LOG_FILE"
    exit 1
fi

echo "$SCRIPT_NAME[$$]: how much time do I have?" > "$CUCKOO_PIPE"
sleep 1

N=$(grep "$SCRIPT_NAME\[$$\]" /root/practice3/cuckoo.log | tail -n 1 | awk '{print $NF}')

if ! [[ "$N" =~ ^[0-9]+$ ]]; then
    N=5
fi

sleep "$N"

echo "$(date '+%Y-%m-%d %H:%M:%S') [$$] Скрипт завершился, работал $N секунд." >> "$LOG_FILE"
