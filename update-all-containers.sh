#!/bin/bash
# update all containers within proxmox; starts stopped containers and shuts them off after its done updating too.
# original script was taken from https://forum.proxmox.com/threads/update-all-lxc-with-one-simple-script.58729/

currTime=$(date '+%Y-%m-%d_%H:%M:%S')
mkdir -p /root/update-logs
LOGS=/root/update-logs/update-$currTime.log

# list of container ids we need to iterate through
containers=$(pct list | tail -n +2 | cut -f1 -d' ')

function update_container() {
  container=$1
  name=$(pct exec "$container" cat /etc/hostname)
  echo "[Info] Updating $container : $name $currTime" | tee -a "$LOGS"
  # to chain commands within one exec we will need to wrap them in bash
  pct exec "$container" -- bash -c "apt update && apt upgrade -y && apt full-upgrade -y && apt autoremove -y"
}

for container in $containers
do
  status=$(pct status "$container")
  if [ "$status" == "status: stopped" ]; then
    echo "[Info] Starting $container : $name $currTime" | tee -a "$LOGS"
    pct start "$container"
    echo "[Info] Sleeping 5 seconds"
    sleep 5
    update_container "$container"
    echo "[Info] Shutting down $container : $name $currTime" | tee -a "$LOGS"
    pct shutdown "$container" &
  elif [ "$status" == "status: running" ]; then
    echo "[Info] $container : $name already running $currTime" | tee -a "$LOGS"
    update_container "$container"
  fi
done; wait
