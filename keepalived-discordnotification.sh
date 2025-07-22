# this script sends a discord notification to a specified channel with the webhook when the keepalived state changes.

#    add the lines below to /etc/keepalived/keepalived.conf. See https://keepalived.readthedocs.io/en/latest/configuration_synopsis.html for syntax.
#    notify_master "/path_to_script/script_master.sh INSTANCE VI_NAME MASTER"
#    notify_backup ""/path_to_script/script_master.sh INSTANCE VI_NAME BACKUP"
#    notify_fault "/path_to_script/script_master.sh INSTANCE VI_NAME FAULT"
#    to run scripts with keepalived, need to add the following global_defs to the keepalived.conf and create a non-root user
#global_defs {
#	enable_script_security
#	script_user keepaliveuser }

#!/bin/bash
TYPE=$1
NAME=$2
STATE=$3

WEBHOOK_URL="insert the webhook here"

HOST=$(hostname)
TIMESTAMP=$(date +"%Y-%m-%d %T")

JSON_PAYLOAD=$(cat <<EOF
{
  "content": "Keepalived State Change",
  "embeds": [{
    "title": "State Transition",
    "color": $(if [ "$STATE" = "MASTER" ]; then echo "65280"; elif [ "$STATE" = "BACKUP" ]; then echo "16776960"; else echo "16711680"; fi), #the numbers are decimal integer values converted from hex codes. master is green, backup is yellow, fault is red.
    "fields": [
      {"name": "Host", "value": "$HOST", "inline": true},
      {"name": "Instance", "value": "$NAME", "inline": true},
      {"name": "New State", "value": "$STATE", "inline": true},
      {"name": "Event Type", "value": "$TYPE", "inline": true},
      {"name": "Timestamp", "value": "$TIMESTAMP", "inline": true}
    ]
  }]
}
EOF
)

curl -s -H "Content-Type: application/json" -X POST -d "$JSON_PAYLOAD" "$WEBHOOK_URL"
