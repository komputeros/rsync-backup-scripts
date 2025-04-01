#!/bin/bash

SRC_DIRS=(
    "/home/havoc/data1"
    "/home/havoc/data2/data3"
)

REMOTE_USER="backup_client"
REMOTE_HOST="backup.serwer.pl"
REMOTE_PORT="22"
REMOTE_BASE="/backup/latest"

for src in "${SRC_DIRS[@]}"; do
    rsync -azR --delete \
        --link-dest="$REMOTE_BASE" \
        -e "ssh -p $REMOTE_PORT" \
        "$src" "$REMOTE_USER@$REMOTE_HOST:$REMOTE_BASE/"
done

# Wysłanie sygnału zakończenia
ssh -p "$REMOTE_PORT" "$REMOTE_USER@$REMOTE_HOST" "touch $REMOTE_BASE/done.flag"
