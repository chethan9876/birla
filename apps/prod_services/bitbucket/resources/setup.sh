#!/bin/bash

# Load EBS Volume
# lsblk command to view your available disk devices
sudo mkdir /data
sudo mkfs -t ext4 /dev/xvdb
sudo mount /dev/xvdb /data
sudo chown -R core:core /data

# set timezone to Melbourne, Australia
sudo timedatectl set-timezone Australia/Melbourne
mv /tmp/resources/docker-compose.yml /home/core/docker-compose.yml

#Install docker-compose
sudo mkdir -p /opt/bin
sudo chown -R core:core /opt/bin
curl -L `curl -s https://api.github.com/repos/docker/compose/releases/latest | jq -r '.assets[].browser_download_url | select(contains("Linux") and contains("x86_64"))'` > /opt/bin/docker-compose
chmod +x /opt/bin/docker-compose

#Setup data folder
sudo mkdir -p /data/bitbucket
sudo chmod -R 777 /data

# Start docker on reboot
sudo systemctl enable docker

cd /home/core
docker login docker.rtsprod.net -u redflex -p redflex
/opt/bin/docker-compose pull --parallel
/opt/bin/docker-compose up -d