#!/bin/bash

yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

yum -y install docker-ce nfs-utils unzip git

# Start docker on reboot
systemctl enable docker
systemctl start docker


mkdir -p /usr/share/redflex/redflex-helm-charts
mkdir -p /usr/share/redflex/alcyon-install/
chmod -R 777 /usr/share/redflex
usermod -aG docker ec2-user
docker login ${docker_registry_domain} -u redflex -p redflex


# Install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install --install-dir /usr/local/aws-cli --bin-dir /usr/local/bin
rm -r aws
rm awscliv2.zip


# Installing kubectl
curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.21.4/bin/linux/amd64/kubectl
curl -L https://raw.githubusercontent.com/warrensbox/terraform-switcher/release/install.sh | bash
mv kubectl /usr/bin/kubectl
chmod 555 /usr/bin/kubectl

# Installing helm
curl -LO --silent --show-error https://get.helm.sh/helm-v3.6.3-linux-amd64.tar.gz
tar -xvf helm-v3.6.3-linux-amd64.tar.gz
mv linux-amd64/helm /usr/bin/helm
chmod 555 /usr/bin/helm

# Installing helm diff plugin
helm plugin install "https://github.com/databus23/helm-diff" --version v3.1.3


# Mount EFS
mkdir /data
cp /etc/fstab /etc/fstab.orig

# <file system>     <dir>       <type>   <options>   <dump>	<pass>
echo "${efs_dns_name}:/ /data/  nfs      defaults    0       0" >> /etc/fstab
mount -a

# Setup mount points
mkdir -p /data/alcyon
mkdir -p /data/alcyon-control
mkdir -p /data/alcyonfs
mkdir -p /data/alcyongreen
mkdir -p /data/arm/upload
mkdir -p /data/calgarytransformr
mkdir -p /data/collectr
mkdir -p /data/ingestr
mkdir -p /data/ledgr
mkdir -p /data/mediaserver
mkdir -p /data/monitoring
mkdir -p /data/rundeck
mkdir -p /data/seekr
mkdir -p /data/trafficstatsingestr
mkdir -p /data/utility/vault
mkdir -p /data/wizard
mkdir -p /data/zincr
mkdir -p /data/alcyon/inbound/courtelection
mkdir -p /data/alcyon/inbound/generalcorr
mkdir -p /data/alcyon/inbound/nominations
mkdir -p /data/alcyon/inbound/returnedmail
mkdir -p /data/alcyon/inbound/statusupdates
mkdir -p /data/alcyon/inbound/locations
mkdir -p /data/alcyon/outbound/notices
chmod -R 777 /data

#okta login config file
#!/bin/bash
cat <<'EOF' >> /usr/share/redflex/.okta_aws_login_config
[DEFAULT]
okta_org_url = https://redflex.okta.com
okta_auth_server =
client_id =
gimme_creds_server = appurl
aws_rolename = all
write_aws_creds = True
cred_profile = prod
okta_username =
app_url =
resolve_aws_alias = True
preferred_mfa_type = push
remember_device = True
aws_default_duration = 3600
device_token =

[prod]
okta_org_url = https://redflex.okta.com
okta_auth_server =
client_id =
gimme_creds_server = appurl
aws_rolename = all
write_aws_creds = True
cred_profile = prod
okta_username =
app_url = https://redflex.okta.com/home/amazon_aws/0oadh3ie2tZABxOuy356/272
resolve_aws_alias = True
preferred_mfa_type = push
remember_device = True
aws_default_duration = 3600
device_token =

[canada]
okta_org_url = https://redflex.okta.com
okta_auth_server =
client_id =
gimme_creds_server = appurl
write_aws_creds = True
cred_profile = canada
okta_username =
app_url = https://redflex.okta.com/home/amazon_aws/0oav82zmewzlXKSax356/272
resolve_aws_alias = True
preferred_mfa_type = push
remember_device = True
aws_default_duration = 3600
device_token =

[demo]
okta_org_url = https://redflex.okta.com
okta_auth_server =
client_id =
gimme_creds_server = appurl
write_aws_creds = True
cred_profile = demo
okta_username =
app_url = https://redflex.okta.com/home/amazon_aws/0oapecmczNDFXf3qS356/272
resolve_aws_alias = True
preferred_mfa_type = push
remember_device = True
aws_default_duration = 3600
device_token =

[us-govcloud]
okta_org_url = https://redflexusa.okta.com
okta_auth_server =
client_id =
gimme_creds_server = appurl
write_aws_creds = True
cred_profile = us-govcloud
okta_username =
app_url = https://redflexusa.okta.com/home/amazon_aws/0oa1ibhvg5dEuuzYx0h8/272
resolve_aws_alias = True
preferred_mfa_type = push
remember_device = True
aws_default_duration = 3600
device_token =

[govcloud]
okta_org_url = https://redflexusa.okta.com
okta_auth_server =
client_id =
gimme_creds_server = appurl
write_aws_creds = True
cred_profile = govcloud
okta_username =
app_url = https://redflexusa.okta.com/home/amazon_aws/0oa1ibhvg5dEuuzYx0h8/272
resolve_aws_alias = True
preferred_mfa_type = push
remember_device = True
aws_default_duration = 3600
device_token =

[us-govcloud-parent]
okta_org_url = https://redflexusa.okta.com
okta_auth_server =
client_id =
gimme_creds_server = appurl
write_aws_creds = True
cred_profile = us-govcloud-parent
okta_username =
app_url = https://redflexusa.okta.com/home/amazon_aws/0oa1hs9yrlzwYip3L0h8/272
resolve_aws_alias = True
preferred_mfa_type = push
remember_device = True
aws_default_duration = 3600
device_token =

[cask]
okta_org_url = https://redflex.okta.com
okta_auth_server =
client_id =
gimme_creds_server = appurl
write_aws_creds = True
cred_profile = cask
okta_username =
app_url = https://redflex.okta.com/home/amazon_aws/0oa25wejv8JHOgTq2357/272
resolve_aws_alias = True
preferred_mfa_type = push
remember_device = True
aws_default_duration = 3600
device_token =

[rms]
okta_org_url = https://redflex.okta.com
okta_auth_server =
client_id =
gimme_creds_server = appurl
write_aws_creds = True
cred_profile = rms
okta_username =
app_url = https://redflex.okta.com/home/amazon_aws/0oadw114ohQ58r7FG356/272
resolve_aws_alias = True
preferred_mfa_type = push
remember_device = True
aws_default_duration = 3600
device_token =

[ca-calgary]
okta_org_url = https://gtsmgt.okta.com
okta_auth_server =
client_id =
gimme_creds_server = appurl
write_aws_creds = True
cred_profile = ca-calgary
okta_username =
app_url = https://gtsmgt.okta.com/home/amazon_aws/0oa1mezzgrCXNkZZ0696/272
resolve_aws_alias = True
preferred_mfa_type = push
remember_device = True
aws_default_duration = 3600
device_token =

[mr-bean]
okta_org_url = https://redflex.okta.com
okta_auth_server =
client_id =
gimme_creds_server = appurl
write_aws_creds = True
cred_profile = mr-bean
okta_username =
app_url = https://redflex.okta.com/home/amazon_aws/0oadvy1agDJzIz3w3356/272
resolve_aws_alias = True
preferred_mfa_type = push
remember_device = True
aws_default_duration = 3600
device_token =

[neo]
okta_org_url = https://redflex.okta.com
okta_auth_server =
client_id =
gimme_creds_server = appurl
write_aws_creds = True
cred_profile = neo
okta_username =
app_url = https://redflex.okta.com/home/amazon_aws/0oadvy1agDJzIz3w3356/272
resolve_aws_alias = True
preferred_mfa_type = push
remember_device = True
aws_default_duration = 3600
device_token =

[us-everise]
okta_org_url = https://redflex.okta.com
okta_auth_server =
client_id =
gimme_creds_server = appurl
write_aws_creds = True
cred_profile = us-everise
okta_username =
app_url = https://redflex.okta.com/home/amazon_aws/0oaetbrsieOUmjMXD357/272
resolve_aws_alias = True
preferred_mfa_type = push
remember_device = True
aws_default_duration = 3600
device_token =
aws_appname =
aws_rolename =
include_path = False
output_format =

[us-fieldservices]
okta_org_url = https://redflex.okta.com
okta_auth_server =
client_id =
gimme_creds_server = appurl
write_aws_creds = True
cred_profile = us-fieldservices
okta_username =
app_url = https://redflex.okta.com/home/amazon_aws/0oaf5w133jdYhQTj1357/272
resolve_aws_alias = True
preferred_mfa_type = push
remember_device = True
aws_default_duration = 3600
device_token =
aws_appname =
aws_rolename =
include_path = False
output_format =
EOF

# kube login file
cat <<'EOF' >> /usr/share/redflex/kubernetes-login.sh
gimme-aws-creds --profile ${client}
export AWS_REGION=${region}
aws eks update-kubeconfig --name ${cluster_name} --profile ${client}
EOF

# alcyon install script
cat <<'EOF' >> /usr/share/redflex/alcyon-install/install.sh
#!/usr/bin/env bash
export SYS_USERNAME=administrator@RTS
export SYS_PASSWORD=Install123$
export DEP_USERNAME=administrator@RTS
export DEP_PASSWORD=Install123$
export PegaServerUrl="https://alc-api.${environment}.${root_domain}/alcyon-bg/im"
export PACKAGE_FILE=/app/packages_${pega_layer}.txt
export FORCE_IMPORT="false"
echo Installing alcyon
/app/packages.sh importLocal | tee /data/logs/install_`date '+%Y%m%d_%H%M%S'`.log
EOF

# alcyon install script
cat <<'EOF' >> /usr/share/redflex/alcyon-install/hotfixes.sh
#!/usr/bin/env bash
export SYS_USERNAME=administrator@RTS
export SYS_PASSWORD=Install123$
export DEP_USERNAME=administrator@RTS
export DEP_PASSWORD=Install123$
export PegaServerUrl="https://alc-api.${environment}.${root_domain}/alcyon-bg/im"
echo Installing pega hotfixes
/app/hotfixes.sh | tee /data/logs/hotfixes_`date '+%Y%m%d_%H%M%S'`.log
EOF
chmod -R 777 /usr/share/redflex/alcyon-install/

${additional_user_data}