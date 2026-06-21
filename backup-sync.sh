#!/bin/bash
#this is specifically designed for Unraid 
# Check if the array is started
if ! mountpoint -q /mnt/user; then
  echo "=== Array not started, aborting: $(date) ===" >> "/boot/fastfiles-sync-logs/fastfiles-sync-error.log"
  exit 1
fi

LOG="*insert log path here*/fastfiles_logs/fastfiles-sync$(date +%Y-%m-%d).log" #insert your own log path here
mkdir -p "$(dirname "$LOG")"
touch "$LOG"
#find any log file thats more than 365 days old and delete it
find /*insert log path here*/fastfiles_logs/ -name "fastfiles-sync*.log" -mtime +365 -delete #insert your own log path here


TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)
INCREMENTAL_DIR="/*path here*/incremental/inc_$TIMESTAMP" #the incremental backup directory with timestamp



echo "=== rsync started: $(date) ===" >> "$LOG"

rsync -avh --progress --backup --backup-dir="$INCREMENTAL_DIR" \
  --exclude={"incremental/","fastfiles_logs/"} --delete --itemize-changes \
  /src_path here*** \ #insert the src path here
  /tgt_path here*** \ #insert the tgt path here
  >> "$LOG" 2>&1

echo "=== rsync finished: $(date) ===" >> "$LOG"
