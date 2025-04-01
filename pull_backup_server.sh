#!/bin/bash

SRC_USER="backup"
SRC_HOST="192.168.1.10"
SRC_PORT="22"

SRC_DIRS=(
    "/home/user/data1"
    "/home/user/data2"
)

REMOTE_PRE_COMMANDS=(
    "/usr/local/bin/przygotuj_backup_mysql.sh"
    "/usr/local/bin/zrzut_logow.sh"
)

POST_ROTATE_SCRIPT="/etc/backup/post_backup.sh"

DEST_BASE="/backup"
DATE=$(date +%F)
DEST="$DEST_BASE/backup_$DATE"
LATEST="$DEST_BASE/latest"
LOGFILE="/var/log/backup_rotation.log"

echo "[$(date)] START backupu pull z $SRC_HOST" >> "$LOGFILE"

for cmd in "${REMOTE_PRE_COMMANDS[@]}"; do
    echo "[$(date)] Wykonuję zdalne polecenie: $cmd" >> "$LOGFILE"
    ssh -p "$SRC_PORT" "$SRC_USER@$SRC_HOST" "$cmd" >> "$LOGFILE" 2>&1
    if [ $? -ne 0 ]; then
        echo "[$(date)] BŁĄD: Zdalne polecenie nie powiodło się: $cmd" >> "$LOGFILE"
        exit 1
    fi
done

mkdir -p "$DEST"

for dir in "${SRC_DIRS[@]}"; do
    if [ -e "$LATEST" ]; then
        rsync -azR --delete --link-dest="$LATEST" -e "ssh -p $SRC_PORT" "$SRC_USER@$SRC_HOST:$dir" "$DEST/"
    else
        rsync -azR --delete -e "ssh -p $SRC_PORT" "$SRC_USER@$SRC_HOST:$dir" "$DEST/"
    fi
done

ln -sfn "$DEST" "$LATEST"

/etc/backup/rotate.sh
ROTATE_RESULT=$?

if [ $ROTATE_RESULT -eq 0 ] && [ -x "$POST_ROTATE_SCRIPT" ]; then
    echo "[$(date)] Uruchamiam post-rotacyjny skrypt: $POST_ROTATE_SCRIPT" >> "$LOGFILE"
    bash "$POST_ROTATE_SCRIPT" >> "$LOGFILE" 2>&1
fi

touch "$LATEST/done.flag"

echo "[$(date)] BACKUP zakończony." >> "$LOGFILE"
