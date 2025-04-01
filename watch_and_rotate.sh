#!/bin/bash

FLAG="/backup/latest/done.flag"
ROTATE_SCRIPT="/etc/backup/rotate.sh"
LOGFILE="/var/log/backup_rotation.log"

if [ -f "$FLAG" ]; then
    echo "[$(date)] Wykryto zakończenie backupu. Rotacja..." >> "$LOGFILE"
    bash "$ROTATE_SCRIPT"
    rm -f "$FLAG"
fi
