#!/bin/bash

#Install docker-compose
sudo mkdir -p /opt/bin
sudo chown -R core:core /opt/bin
curl -L `curl -s https://api.github.com/repos/docker/compose/releases/latest | jq -r '.assets[].browser_download_url | select(contains("Linux") and contains("x86_64"))'` > /opt/bin/docker-compose
chmod +x /opt/bin/docker-compose

# Start docker on reboot
sudo systemctl enable docker
/opt/bin/docker-compose up -d --scale chrome=6