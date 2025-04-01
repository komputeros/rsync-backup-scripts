#!/bin/bash

BACKUP_DIR="/backup"
LOGFILE="/var/log/backup_rotation.log"
LATEST="$BACKUP_DIR/latest"

KEEP_DAYS=0
KEEP_WEEKS=6
KEEP_MONTHS=2

echo "[$(date)] ROTACJA START" >> "$LOGFILE"

cd "$BACKUP_DIR" || exit 1
BACKUPS=( $(ls -1d backup_20* 2>/dev/null | sort) )
BACKUP_DATES=()

for b in "${BACKUPS[@]}"; do
    BACKUP_DATES+=("${b#backup_}")
done

declare -A KEEP_MAP=()

for d in "${BACKUP_DATES[@]: -$KEEP_DAYS}"; do
    KEEP_MAP["$d"]=1
done

for i in $(seq 0 $((KEEP_WEEKS - 1))); do
    week_start=$(date -d "last sunday - $i weeks" +%Y-%m-%d)
    week_end=$(date -d "$week_start +6 days" +%Y-%m-%d)
    for ((j=${#BACKUP_DATES[@]}-1; j>=0; j--)); do
        d=${BACKUP_DATES[$j]}
        [[ "$d" > "$week_start" && "$d" < "$week_end" ]] && { KEEP_MAP["$d"]=1; break; }
    done
done

for i in $(seq 0 $((KEEP_MONTHS - 1))); do
    month_start=$(date -d "-$i months" +%Y-%m-01)
    month_end=$(date -d "$month_start +1 month -1 day" +%Y-%m-%d)
    for ((j=${#BACKUP_DATES[@]}-1; j>=0; j--)); do
        d=${BACKUP_DATES[$j]}
        [[ "$d" > "$month_start" && "$d" < "$month_end" ]] && { KEEP_MAP["$d"]=1; break; }
    done
done

for b in "${BACKUPS[@]}"; do
    d=${b#backup_}
    if [[ -z "${KEEP_MAP[$d]}" && "$BACKUP_DIR/$b" != "$LATEST" ]]; then
        echo "[$(date)] Usuwam: $b" >> "$LOGFILE"
        rm -rf "$BACKUP_DIR/$b"
    else
        echo "[$(date)] Zachowuję: $b" >> "$LOGFILE"
    fi
done

echo "[$(date)] ROTACJA KONIEC" >> "$LOGFILE"
