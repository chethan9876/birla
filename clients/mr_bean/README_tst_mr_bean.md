# Mr Bean Test environment

Test environment for all products. 

## Pre requisites

1. Create the following keypairs 
   1. "tst-mr-bean-core-apps-eks-key" keypair with "Key pair type" as "RSA" and "Private key file format" as ".pem" for EKS nodes.
   2. "tst-mr-bean-jumpbox-key" keypair with "Key pair type" as "RSA" and "Private key file format" as ".pem" for EKS nodes.
2. Create "tst-mr-bean-common-rds-kms" key in KMS with Role_1 as the key user and all other options set to defaults
//5. Login into AWS Security account and add the new account to the S3 bucket allow policy
//
//   * In `redflexsec-awsconfig-logs` bucket add `"arn:aws:s3:::redflexsec-awsconfig-logs/aws-config/AWSLogs/701680912783/*"`
//   * In `redflexsec-cloudtrail-logs` bucket add `"arn:aws:s3:::redflexsec-cloudtrail-logs/cloudtrail/AWSLogs/701680912783/*"`

## Setup env with Terraform

1. `rm -R .terraform/terraform.state`
2. `terraform init -backend-config="tst_mr_bean_backend.config"`
3. `terraform plan --var-file=tst_mr_bean.tfvars -target=module.core_network`
4. `terraform apply --var-file=tst_mr_bean.tfvars -target=module.core_network`
5. `terraform plan --var-file=tst_mr_bean.tfvars`
6. `terraform apply --var-file=tst_mr_bean.tfvars`

## S3 data copy

To copy data from existing S3 bucket to new S3 bucket in case of migration, use the following command:
`aws s3 sync s3://EXAMPLE-BUCKET-SOURCE s3://EXAMPLE-BUCKET-TARGET`
   ````
   aws s3 sync s3://alcyon-neo-media  s3://tst-mr-bean-alcyon-backoffice-media-s3 & 
   aws s3 sync s3://alcyon-neo-preview-media  s3://tst-mr-bean-alcyon-backoffice-preview-media-s3	&
   aws s3 sync s3://alcyon-neo-template  s3://tst-mr-bean-alcyon-backoffice-template-s3 &
   aws s3 sync s3://alcyon-control-neo-ccu-data  s3://tst-mr-bean-alcyon-control-ccu-data-s3 &
   aws s3 sync s3://alcyon-control-neo-reviewr  s3://tst-mr-bean-alcyon-control-reviewr-s3 &
   aws s3 sync s3://alcyon-control-neo-timeseries-data  s3://tst-mr-bean-alcyon-control-timeseries-data-s3 &
   aws s3 sync s3://alcyon-fs-neo-media  s3://tst-mr-bean-alcyon-field-service-media-s3 &
   ````

## Calico network policy

https://docs.aws.amazon.com/eks/latest/userguide/alternate-cni-plugins.html
https://docs.projectcalico.org/getting-started/kubernetes/managed-public-cloud/eks

Run the aws-kubernetes-tools container on the admin box.
`ssh-add ~/.ssh/tst-mr-bean-common-key.pem`
`ssh -J ec2-user@jumpbox.stg.redflexcask.onl ec2-user@admin.stg.redflexcask.onl`
`docker login dockerp.rtsprod.net -u redflex`
`docker run -it --rm dockerp.rtsprod.net/common/aws-kubernetes-tools:latest`

In container:
`gimme-aws-creds --profile mr-bean`
`export AWS_REGION=us-west-2`
`aws eks --profile mr-bean update-kubeconfig --name tst-mr-bean-eks`

````
kubectl delete daemonset -n kube-system aws-node

curl -o calico-vxlan.yaml https://projectcalico.docs.tigera.io/manifests/calico-vxlan.yaml
#EDIT CALICO_IPV4POOL_CIDR and set value: "172.21.0.0/16"
kubectl create -f calico-vxlan.yaml
kubectl get pods -n kube-system
````

### Recreate node group

Switching the CNI (aws-node) to Calico requires the node group to be deleted and recreated.
Easiest way to do this is to delete 2 nodes and let auto-scaling group recreate the 2 nodes.

### References
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance
https://learn.hashicorp.com/terraform/aws/eks-intro
https://docs.aws.amazon.com/eks/latest/userguide/load-balancing.html
https://www.terraform.io/docs/providers/aws/r/eks_node_group.html
https://aws.amazon.com/premiumsupport/knowledge-center/amazon-eks-cluster-access/




