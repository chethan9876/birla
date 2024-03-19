# Harbor

Runs on Redhat CIS 8 image.

## Steps

### Mount drive

````bash
sudo su - 
cp /etc/fstab /etc/fstab.orig
mkdir /data
mkfs -t ext4 /dev/nvme1n1
mount /dev/nvme1n1 /data
echo /dev/nvme1n1  /data ext4 defaults,nofail 0 2 >> /etc/fstab
chown -R ec2-user:ec2-user /data

````

### Setup tools

````bash
sudo sysctl -w net.ipv4.ip_forward=1

# Setup Docker - 19.03, NFS utils, etc
#https://github.com/kubernetes/kubernetes/blob/master/vendor/k8s.io/system-validators/validators/docker_validator.go#L52
yum -y update
yum install -y yum-utils device-mapper-persistent-data lvm2 wget nfs-utils

# dnf repolist -v

yum-config-manager -y --add-repo https://download.docker.com/linux/centos/docker-ce.repo
# Latest docker version installation has issues in installing containerd.io
yum install docker-ce-18.09.1 


## Create /etc/docker directory.
mkdir /etc/docker

# Setup daemon.
cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2",
  "storage-opts": [
    "overlay2.override_kernel_check=true"
  ]
}
EOF

mkdir -p /etc/systemd/system/docker.service.d

# Restart Docker
systemctl daemon-reload
systemctl enable docker.service
systemctl restart docker

# Install docker-compose
curl -L "https://github.com/docker/compose/releases/download/1.25.5/docker-compose-$(uname -s)-$(uname -m)" -o /usr/bin/docker-compose
chmod +x /usr/bin/docker-compose

# Disable firewall
systemctl stop firewalld
systemctl disable firewalld

sysctl --system

````

### Generate HTTPS Key
 
 ````bash
 mkdir cert/ 
 cd cert
 openssl genrsa -out ca.key 4096
 openssl req -x509 -new -nodes -sha512 -days 3650 \
  -subj "/C=AU/ST=Victoria/L=Melbourne/O=harbor/OU=Engineering/CN=harbor.rtsprod.net" \
  -key ca.key \
  -out ca.crt
 
 openssl genrsa -out harbor.rtsprod.net.key 4096
 openssl req -sha512 -new \
     -subj "/C=AU/ST=Victoria/L=Melbourne/O=harbor/OU=Engineering/CN=harbor.rtsprod.net" \
     -key harbor.rtsprod.net.key \
     -out harbor.rtsprod.net.csr

cat > v3.ext <<-EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names

[alt_names]
DNS.1=harbor.rtsprod.net
DNS.2=harborext.rtsprod.net
DNS.3=harbor-int.rtsprod.net
EOF
     
openssl x509 -req -sha512 -days 3650 \
 -extfile v3.ext \
 -CA ca.crt -CAkey ca.key -CAcreateserial \
 -in harbor.rtsprod.net.csr \
 -out harbor.rtsprod.net.crt

cp harbor.rtsprod.net.crt /data/cert/
cp harbor.rtsprod.net.key /data/cert/
 
openssl x509 -inform PEM -in harbor.rtsprod.net.crt -out harbor.rtsprod.net.cert

sudo mkdir -p /etc/docker/certs.d/harbor.rtsprod.net
sudo cp ca.crt /etc/docker/certs.d/harbor.rtsprod.net

````                
mkdir -p /data/cert/
cp harbor.rtsprod.net.crt /data/cert/
cp harbor.rtsprod.net.key /data/cert/

wget https://github.com/goharbor/harbor/releases/download/v2.0.0/harbor-offline-installer-v2.0.0.tgz
tar xvf harbor-offline-installer-v2.0.0.tgz

cp harbor.yml.tmpl harbor.yml

Edit harbor.yml

### Setup DB

````sql
CREATE ROLE harbor WITH LOGIN PASSWORD 'HarborS#cr#t' NOSUPERUSER INHERIT NOCREATEDB NOCREATEROLE NOREPLICATION;
CREATE ROLE clair WITH LOGIN PASSWORD 'ClairS#cr#t' NOSUPERUSER INHERIT NOCREATEDB NOCREATEROLE NOREPLICATION;
CREATE DATABASE harbordb WITH OWNER = harbor ENCODING = 'UTF8' CONNECTION LIMIT = -1;
CREATE DATABASE clairdb WITH OWNER = clair ENCODING = 'UTF8' CONNECTION LIMIT = -1;

````

### Setup harbor

`ssh -i ~/.ssh/USA_Prod_harbor_repo_kp.pem ec2-user@harbor-int.rtsprod.net`

````bash
cd harbor
sudo ./install.sh --with-clair --with-chartmuseum
````

## Usage

### Robot account login

````
docker login  -u 'robot$Test' -p xxxxx harbor.rtsprod.net
````

### Helm chart

````
helm repo add --username vnannan --pasword <cli-secret> harbor-alcyon https://harbor.rtsprod.net/chartrepo/alcyon
````

## Reference
https://goharbor.io/docs/2.0.0/install-config/configure-https/

https://github.com/docker/docker.github.io/blob/master/registry/storage-drivers/s3.md
