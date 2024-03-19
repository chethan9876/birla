# Mr Bean Test environment

Test environment for all products. 

## Pre requisites

1. Create the following keypairs
   1. "prd-au-qld-core-apps-eks-key" keypair with "Key pair type" as "RSA" and "Private key file format" as ".pem" for EKS nodes.
   2. "prd-au-qld-jumpbox-key" keypair with "Key pair type" as "RSA" and "Private key file format" as ".pem" for jumpbox.
   3. "prd-au-qld-itsvc-ec2-key" keypair with "Key pair type" as "RSA" and "Private key file format" as ".pem" for itsvc ec2.
   3. "prd-au-qld-dc-ec2-key" keypair with "Key pair type" as "RSA" and "Private key file format" as ".pem" for domain controller ec2.
2. Create "prd-au-qld-common-rds-kms" key in KMS with Role_1 as the key user and all other options set to defaults
3. create s3 bucket for state file
4. create domain controller secret for domain join

## Setup env with Terraform

### STG server

1. `rm .terraform/terraform.tfstate`
2. `terraform init -backend-config="stg_au_qld_backend.config"`
3. `terraform plan --var-file=stg_au_qld.tfvars -target=module.core_network`
4. `terraform apply --var-file=stg_au_qld.tfvars -target=module.core_network`
3. `terraform plan --var-file=stg_au_qld.tfvars -target=module.core_services`
4. `terraform apply --var-file=stg_au_qld.tfvars -target=module.core_services`
3. `terraform plan --var-file=stg_au_qld.tfvars -target=module.core_apps`
4. `terraform apply --var-file=stg_au_qld.tfvars -target=module.core_apps`
5. `terraform plan --var-file=stg_au_qld.tfvars`
6. `terraform apply --var-file=stg_au_qld.tfvars`

### SYS server

1. `rm .terraform/terraform.tfstate`
2. `terraform init -backend-config="sys_au_qld_backend.config"`
3. `terraform plan --var-file=sys_au_qld.tfvars -target=module.core_network`
4. `terraform apply --var-file=sys_au_qld.tfvars -target=module.core_network`
3. `terraform plan --var-file=sys_au_qld.tfvars -target=module.core_services`
4. `terraform apply --var-file=sys_au_qld.tfvars -target=module.core_services`
3. `terraform plan --var-file=stg_au_qld.tfvars -target=module.core_apps`
4. `terraform apply --var-file=stg_au_qld.tfvars -target=module.core_apps`
5. `terraform plan --var-file=sys_au_qld.tfvars`
6. `terraform apply --var-file=sys_au_qld.tfvars`

### UAT server

1. `rm .terraform/terraform.tfstate`
2. `terraform init -backend-config="uat_au_qld_backend.config"`
3. `terraform plan --var-file=uat_au_qld.tfvars -target=module.core_network`
4. `terraform apply --var-file=uat_au_qld.tfvars -target=module.core_network`
3. `terraform plan --var-file=uat_au_qld.tfvars -target=module.core_services`
4. `terraform apply --var-file=uat_au_qld.tfvars -target=module.core_services`
3. `terraform plan --var-file=stg_au_qld.tfvars -target=module.core_apps`
4. `terraform apply --var-file=stg_au_qld.tfvars -target=module.core_apps`
5. `terraform plan --var-file=uat_au_qld.tfvars`
6. `terraform apply --var-file=uat_au_qld.tfvars`

### PRD server

1. `rm .terraform/terraform.tfstate`
2. `terraform init -backend-config="prd_au_qld_backend.config"`
3. `terraform plan --var-file=prd_au_qld.tfvars -target=module.core_network`
4. `terraform apply --var-file=prd_au_qld.tfvars -target=module.core_network`
3. `terraform plan --var-file=prd_au_qld.tfvars -target=module.core_services`
4. `terraform apply --var-file=prd_au_qld.tfvars -target=modulecore_services`
3. `terraform plan --var-file=prd_au_qld.tfvars -target=module.core_apps`
4. `terraform apply --var-file=prd_au_qld.tfvars -target=module.core_apps`
5. `terraform plan --var-file=prd_au_qld.tfvars`
6. `terraform apply --var-file=prd_au_qld.tfvars`

## POST SETUP

***IMPORTANT***

Once the environment is created and hlem charts run you will need to go to EC2 -> Load balancers in AWS Console
and link the Application load balancer to Network load balancer for rest api nlb.

## Calico network policy

https://docs.aws.amazon.com/eks/latest/userguide/alternate-cni-plugins.html
https://docs.projectcalico.org/getting-started/kubernetes/managed-public-cloud/eks

Run the aws-kubernetes-tools container on the admin box.
`ssh-add ~/.ssh/stg-au-qld-common-key.pem`
`ssh -J ec2-user@jumpbox.stg.redflexqld.onl ec2-user@admin.stg.redflexqld.onl`
`docker login dockerp.rtsprod.net -u redflex`
`docker run -it --rm dockerp.rtsprod.net/common/aws-kubernetes-tools:latest`

In container:
`gimme-aws-creds --profile au-qld`
`export AWS_REGION=ap-southeast-2`
`aws eks --profile au-qld update-kubeconfig --name prd-au-qld-eks`

````
kubectl delete daemonset -n kube-system aws-node

curl -o calico-vxlan.yaml https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/calico-vxlan.yaml
#EDIT CALICO_IPV4POOL_CIDR and set value: "172.21.0.0/16"
kubectl create -f calico-vxlan.yaml
kubectl get pods -n kube-system
````

### Recreate node group

Switching the CNI (aws-node) to Calico requires the node group to be deleted and recreated.
Easiest way to do this is to delete 2 nodes and let auto-scaling group recreate the 2 nodes.

## Increase timeout on the jumpbox and admin box, so you don't get logged out after 5 min

```
sudo vi /etc/profile.d/tmout.sh
# update TMOUT=86400
sudo vi /etc/ssh/sshd_config
# scroll down the bottom and update
# ClientAliveInterval 3600
# ClientAliveCountMax 24
sudo systemctl restart sshd
```

## Create databases and schemas on the hosts:

In alcyon-records-management database run the following
````sql
CREATE ROLE "registrr" WITH LOGIN NOSUPERUSER NOCREATEDB CREATEROLE INHERIT NOREPLICATION CONNECTION LIMIT -1 PASSWORD 'R#g1sTrS#cR3t';
grant registrr to postgres;
CREATE DATABASE registrr WITH OWNER = "registrr" ENCODING = 'UTF8' CONNECTION LIMIT = -1;

-- run this as registrr user
CREATE SCHEMA registrr;
GRANT ALL PRIVILEGES ON SCHEMA registrr TO registrr;
````

In alcyon-backoffice database run the following
````sql
CREATE ROLE "rundeck" WITH LOGIN NOSUPERUSER NOCREATEDB CREATEROLE INHERIT NOREPLICATION CONNECTION LIMIT -1 PASSWORD 'Rund#ckS#cr#t';
grant rundeck to postgres;
CREATE DATABASE rundeckdb WITH OWNER = "rundeck" ENCODING = 'UTF8' CONNECTION LIMIT = -1;
````

## References
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance
https://learn.hashicorp.com/terraform/aws/eks-intro
https://docs.aws.amazon.com/eks/latest/userguide/load-balancing.html
https://www.terraform.io/docs/providers/aws/r/eks_node_group.html
https://aws.amazon.com/premiumsupport/knowledge-center/amazon-eks-cluster-access/




