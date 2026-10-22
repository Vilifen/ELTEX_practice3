#!/bin/bash

CONFIG_FILE="/root/practice3/observer.conf"
LOG_FILE="/root/practice3/observer.log"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "Ошибка: файл конфигурации $CONFIG_FILE не найден."
    exit 1
fi

while IFS= read -r script_name || [ -n "$script_name" ]; do
    [ -z "$script_name" ] && continue

    FULL_PATH="/root/practice3/$script_name"
    
    IS_RUNNING=0
    for cmdline in /proc/[0-9]*/cmdline; do
        pid=$(echo "$cmdline" | cut -d/ -f3)
        [ "$pid" = "$$" ] && continue
        if [ -f "$cmdline" ] && tr '\0' ' ' < "$cmdline" 2>/dev/null | grep -Fq "$FULL_PATH"; then
            IS_RUNNING=1
            break
        fi
    done

    if [ "$IS_RUNNING" -eq 0 ]; then
        if [ -e "$FULL_PATH" ]; then
            echo "$(date '+%Y-%m-%d %H:%M:%S') Скрипт $script_name не найден. Перезапуск." >> "$LOG_FILE"
            nohup /bin/bash "$FULL_PATH" > /dev/null 2>&1 &
        else
            echo "$(date '+%Y-%m-%d %H:%M:%S') Ошибка: файл $FULL_PATH не существует!" >> "$LOG_FILE"
        fi
    fi
done < "$CONFIG_FILE"
