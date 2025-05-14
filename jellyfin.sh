#!/bin/bash

# Set variables
CTID=110
HOSTNAME="jellyfin"
TEMPLATE="local:vztmpl/debian-12-standard_12.0-1_amd64.tar.zst"
STORAGE="local-lvm"
DISK_SIZE="8G"
MEMORY="2048"
CORES="2"
NET_BRIDGE="vmbr0"

echo "[*] Creating container $CTID for Jellyfin..."

# Create the container
pct create $CTID $TEMPLATE \
  --hostname $HOSTNAME \
  --storage $STORAGE \
  --rootfs ${STORAGE}:${DISK_SIZE} \
  --memory $MEMORY \
  --cores $CORES \
  --net0 name=eth0,bridge=$NET_BRIDGE,ip=dhcp \
  --features nesting=1 \
  --unprivileged 1

# Start the container
pct start $CTID
sleep 5

# Install Jellyfin inside the container
echo "[*] Installing Jellyfin inside container $CTID..."

pct exec $CTID -- bash -c "apt update && apt install -y gnupg curl software-properties-common apt-transport-https"

pct exec $CTID -- bash -c "
  curl -fsSL https://repo.jellyfin.org/jellyfin_team.gpg.key | gpg --dearmor -o /usr/share/keyrings/jellyfin.gpg &&
  echo 'deb [signed-by=/usr/share/keyrings/jellyfin.gpg] https://repo.jellyfin.org/debian bookworm main' > /etc/apt/sources.list.d/jellyfin.list &&
  apt update &&
  apt install -y jellyfin
"

echo "[*] Jellyfin installed. You can access it after checking the container's IP:"
pct exec $CTID -- ip a show eth0
