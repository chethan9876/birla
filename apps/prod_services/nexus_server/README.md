# Redflex Servers  

This is a terraform module to create a Core OS instance on AWS and runs following server instances: 

- Nexus OSS
- Sonarqube

## Dependencies

- CoreOS
- Let's Encrypt
- Nexus OSS 3

## Docker images used

- jwilder/nginx-proxy
- jrcs/letsencrypt-nginx -proxy-companion
- sonatype/nexus3:latest
- sonarqube:latest
- mysql:latest

## Increase Volume size

Increase the volume size through console and run the command through shell

````
sudo resize2fs /dev/xvdb
````

## More details

[Nexus](docs/nexus_README.md)

[Sonar](docs/sonar_README.md)

## Usage

````
    terraform apply
````
