#!/bin/bash
# update all containers within proxmox; starts stopped containers and shuts them off after its done updating too.
# original script was taken from https://forum.proxmox.com/threads/update-all-lxc-with-one-simple-script.58729/

currTime=$(date)
echo "$currTime" | tee -a /root/update-log

# list of container ids we need to iterate through
containers=$(pct list | tail -n +2 | cut -f1 -d' ')

function update_container() {
  container=$1
  name=`pct exec $container cat /etc/hostname`
  echo "[Info] Updating $container : $name" | tee -a /root/update-log
  # to chain commands within one exec we will need to wrap them in bash
  pct exec $container -- bash -c "apt update && apt upgrade -y && apt full-upgrade -y && apt autoremove -y"
}

for container in $containers
do
  status=`pct status $container`
  if [ "$status" == "status: stopped" ]; then
    echo "[Info] Starting $container : $name" | tee -a /root/update-log
    pct start $container
    echo "[Info] Sleeping 5 seconds"
    sleep 5
    update_container $container
    echo "[Info] Shutting down $container : $name" | tee -a /root/update-log
    pct shutdown $container &
  elif [ "$status" == "status: running" ]; then
    echo "[Info] $container : $name already running" | tee -a /root/update-log
    update_container $container
  fi
done; wait

cat /root/update-log | less
