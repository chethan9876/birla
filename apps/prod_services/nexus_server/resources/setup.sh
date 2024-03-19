#!/bin/bash

# Load Nexus data EBS Volume
# lsblk command to view your available disk devices
sudo mkdir /data
#sudo mkfs -t ext4 /dev/xvdb # if you mount a snapshot
sudo mount /dev/xvdb /data
sudo chown -R core:core /data

# Nexus docker instance runs as 200..
sudo chown -R 200:200 /data/nexus-data
sudo cp /etc/fstab /etc/fstab.orig

#Create Volumes
mkdir -p /data/nginx/certs
mkdir -p /data/nginx/conf.d
mkdir -p /data/nginx/vhost.d
mkdir -p /data/sonarqube/extensions/jdbc-driver/oracle/
mkdir -p /data/nexus-data

#Move files to correct location
mv /tmp/docker-compose.yml /home/core/docker-compose.yml
mv /tmp/config/file.conf /data/nginx/conf.d/file.conf
#mv /tmp/config/docker_port_ssl.conf /data/nginx/conf.d/docker_port_ssl.conf
mv /tmp/ojdbc6.jar /data/sonarqube/extensions/jdbc-driver/oracle/ojdbc6.jar

#Install docker-compose
sudo mkdir -p /opt/bin
sudo chown -R core:core /opt/bin
curl -L `curl -s https://api.github.com/repos/docker/compose/releases/latest | jq -r '.assets[].browser_download_url | select(contains("Linux") and contains("x86_64"))'` > /opt/bin/docker-compose
chmod +x /opt/bin/docker-compose

# Start docker on reboot
sudo systemctl enable docker

sudo chmod -R 777 /data