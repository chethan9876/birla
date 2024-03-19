# Helm chart installation instruction for Calgary Production EKS cluster

## Cluster login Setup

1. Copy required files and folders using the sample command below
```shell
scp -r -J ec2-user@jumpbox.prd.redflexcalgary.onl <path to redflex-helm-charts>/<required file/folder> ec2-user@admin.prd.redflexcalgary.onl:/usr/share/redflex/redflex-helm-charts/<required file/folder>
```

2. SSH into admin box and exec into aws-kubernetes-tools container
```shell
ssh-add ~/.ssh/prd-ca-calgary-common-key.pem
ssh-add ~/.ssh/prd-ca-calgary-jumpbox-key.pem
ssh -J ec2-user@jumpbox.prd.redflexcalgary.onl ec2-user@admin.prd.redflexcalgary.onl
docker run -it --rm -v /usr/share/redflex/redflex-helm-charts:/data dockerp.rtsprod.net/common/aws-kubernetes-tools:latest
#In the container bash run the following command to generate the aws key
gimme-aws-creds --profile ca-calgary
#Export the EKS kubeconfig
export AWS_REGION=ca-central-1
aws eks --profile ca-calgary update-kubeconfig --name prd-ca-calgary-eks
```
   

## Installation

1. [Install Kubernetes Metrics Server](https://docs.aws.amazon.com/eks/latest/userguide/metrics-server.html)

2. Setup namespaces

 NOTE: Calico policies work based on namespace labels. Adding labels are mandatory.
 
    ````
    kubectl create ns base
    kubectl label namespace/base name=base

    kubectl create ns monitoring
    kubectl label namespace/monitoring name=monitoring
    
    kubectl create ns utility
    kubectl label namespace/utility name=utility

    kubectl create ns alcyon-control
    kubectl label namespace/alcyon-control name=alcyon-control

    kubectl create ns ca-calgary 
    kubectl label namespace/ca-calgary name=ca-calgary

    kubectl create ns alcyon-app
    kubectl label namespace/alcyon-app name=alcyon-app

    kubectl label namespace/default name=default 
    kubectl label namespace/kube-system name=kube-system
    ````
     
3. Setup the image pull secret in all namespaces
    ````
    kubectl create secret docker-registry regsecret --docker-server=dockerp.rtsprod.net --docker-username=<username> --docker-password=<password> --docker-email=cst@redflex.com.au -n <namespace>
    
    #eg., 
    kubectl create secret docker-registry regsecret --docker-server=dockerp.rtsprod.net --docker-username=redflex --docker-password=XXX --docker-email=eng.support@redflex.com -n alcyon-control 
    kubectl create secret docker-registry regsecret --docker-server=dockerp.rtsprod.net --docker-username=redflex --docker-password=XXX --docker-email=eng.support@redflex.com -n ca-calgary 
    kubectl create secret docker-registry regsecret --docker-server=dockerp.rtsprod.net --docker-username=redflex --docker-password=XXX --docker-email=eng.support@redflex.com -n utility 
    kubectl create secret docker-registry regsecret --docker-server=dockerp.rtsprod.net --docker-username=redflex --docker-password=XXX --docker-email=eng.support@redflex.com -n alcyon-app
    ```` 
## EFS Folder creation 

Create the required folders in EFS through Cluster admin instance.
````
mkdir /data/calgarytransformr
mkdir /data/alcyon-control
mkdir /data/monitr-calgarytransformr
sudo chmod 777 -R /data
````

## DB Schema creation

SSH into one of the cluster worker nodes (through admin instance) and run the following commands
```shell
sudo yum install -y postgresql
psql -h prd-ca-calgary-alcyon-control-rds.prd.redflexcalgary.onl -p 5432 -d postgres -U postgres
```
Enter the password when prompted and once in the psql shell run the following commands
````sql
CREATE DATABASE <db_name>;
CREATE ROLE <role_name> WITH LOGIN PASSWORD 'XXXX' NOSUPERUSER NOINHERIT NOCREATEDB NOCREATEROLE NOREPLICATION;

\c <db_name>

CREATE SCHEMA <schema_name>;
DROP SCHEMA public;
GRANT ALL PRIVILEGES ON SCHEMA <schema_name> TO  <role_name>;

-- For Utility Chart
CREATE DATABASE rundeckdb;
CREATE ROLE rundeck WITH LOGIN PASSWORD 'XXXX' NOSUPERUSER NOINHERIT NOCREATEDB NOCREATEROLE NOREPLICATION;

\c rundeckdb

CREATE SCHEMA rundeck;
DROP SCHEMA public;
GRANT ALL PRIVILEGES ON SCHEMA rundeck TO  rundeck;

-- For Alcyon Control Chart
CREATE DATABASE governrdb;
CREATE ROLE governr WITH LOGIN PASSWORD 'XXXX' NOSUPERUSER NOINHERIT NOCREATEDB NOCREATEROLE NOREPLICATION;

\c governrdb

CREATE SCHEMA governr;
DROP SCHEMA public;
GRANT ALL PRIVILEGES ON SCHEMA governr TO  governr;

-- For Calgary Chart
CREATE DATABASE calgary;
CREATE ROLE calgary WITH LOGIN PASSWORD 'XXXX' NOSUPERUSER NOINHERIT NOCREATEDB NOCREATEROLE NOREPLICATION;

\c calgary

CREATE SCHEMA calgary;
DROP SCHEMA public;
GRANT ALL PRIVILEGES ON SCHEMA calgary TO  calgary;
````


## Deploy

### EKS chart

````

# run following first time only:
kubectl annotate ConfigMap aws-auth -n kube-system meta.helm.sh/release-namespace=kube-system
kubectl annotate ConfigMap aws-auth -n kube-system meta.helm.sh/release-name=eks-release
kubectl label ConfigMap aws-auth -n kube-system app.kubernetes.io/managed-by=Helm
 
# To purge the release
helm uninstall -n kube-system eks-release 

helm template eks-release -n kube-system -f ../values-ca-calgary-prd-global.yaml -f values-ca-calgary-prd.yaml . > test.yaml

# To install
helm install eks-release  --namespace kube-system  -f ../values-ca-calgary-prd-global.yaml -f values-ca-calgary-prd.yaml .


# To view diff before upgrade.
helm diff upgrade eks-release --namespace kube-system  -f ../values-ca-calgary-prd-global.yaml -f values-ca-calgary-prd.yaml .

# To upgrade the chart
helm upgrade eks-release --namespace kube-system  -f ../values-`ca-calgary-prd`-global.yaml -f values-ca-calgary-prd.yaml .

# To verify status
helm status eks-release --namespace kube-system
````


### Base chart

````
 
# To purge the release
helm uninstall -n base base-release 

helm dependency update

helm template base-release -n base -f ../values-ca-calgary-prd-global.yaml -f values-ca-calgary-prd.yaml . > test.yaml

# To install
helm install base-release  --namespace base  -f ../values-ca-calgary-prd-global.yaml -f values-ca-calgary-prd.yaml .

# To view diff before upgrade.
helm diff upgrade base-release --namespace base -f ../values-ca-calgary-prd-global.yaml -f values-ca-calgary-prd.yaml .

# To upgrade the chart
helm upgrade base-release --namespace base -f ../values-ca-calgary-prd-global.yaml -f values-ca-calgary-prd.yaml .

# To verify status
helm status base-release
````

### Monitoring chart

````
kubectl create secret generic monitoring-secret --from-literal=GRAFANA_USER='XXX' --from-literal=GRAFANA_PASSWORD='XXXX' -n monitoring

# Run this prior to install, required for nri-bundle (new-relic)
kubectl apply -f https://raw.githubusercontent.com/pixie-labs/pixie/main/k8s/operator/crd/base/px.dev_viziers.yaml
kubectl apply -f https://raw.githubusercontent.com/pixie-labs/pixie/main/k8s/operator/helm/crds/olm_crd.yaml

helm repo add kiwigrid https://kiwigrid.github.io  
helm dependency update

# To purge the release
helm uninstall -n monitoring monitoring-release 

helm template monitoring-release  -f ../values-ca-calgary-prd-global.yaml -f values-ca-calgary-prd.yaml -n monitoring . > test.yaml

# To install
helm install monitoring-release -n monitoring  -f ../values-ca-calgary-prd-global.yaml -f values-ca-calgary-prd.yaml .

helm diff upgrade monitoring-release -n monitoring   -f ../values-ca-calgary-prd-global.yaml -f values-ca-calgary-prd.yaml .

# To upgrade the chart when new subchart is added.
helm upgrade monitoring-release -n monitoring   -f ../values-ca-calgary-prd-global.yaml -f values-ca-calgary-prd.yaml .

# To verify status
helm status monitoring-release

helm uninstall -n monitoring monitoring-release 
````

Once helm chart is deployed, follow the steps in monitoring-chart/README.md file.

## Utility Chart

Prerequisite: Create a Postgres Schema for Rundeck application.
> Refer to [Utility Readme file](utility-chart/README.md) for DB instructions.


````
cd utility-chart

kubectl create secret generic utility-secret --from-literal=RUNDECK_DATABASE_PASSWORD='XXXX' --from-literal=RUNDECK_ALCYON_DB_PASSWORD='XXXX' --from-literal=RUNDECK_ALCYON_ADMIN_PASSWORD='XXXX' --from-literal=BIX_DB_PASSWORD='XXXX' --from-literal=TRAFFIC_STATS_DB_PASSWORD='XXXX' -n utility

helm dependency update

helm template  -f ../values-ca-calgary-prd-global.yaml -f values-ca-calgary-prd.yaml . -n utility-release --namespace utility > test.yaml

helm install --debug --dry-run -n utility-release --namespace utility  -f ../values-ca-calgary-prd-global.yaml -f values-ca-calgary-prd.yaml .

# To install
helm install utility-release --namespace utility  -f ../values-ca-calgary-prd-global.yaml -f values-ca-calgary-prd.yaml .

# To purge the release
helm uninstall -n utility utility-release

# To view diff before upgrade
helm diff upgrade utility-release --namespace utility  -f ../values-ca-calgary-prd-global.yaml -f values-ca-calgary-prd.yaml .

# To run upgrade.
helm upgrade utility-release --namespace utility  -f ../values-ca-calgary-prd-global.yaml -f values-ca-calgary-prd.yaml .

````

## Alcyon Control Chart

````
cd alcyon-control-chart
helm dependency update

kubectl create secret generic alcyon-control-secret --from-literal=GOVERNR_DB_PASSWORD='XXXX' -n alcyon-control

helm template -f ../values-ca-calgary-prd-global.yaml -f values-ca-calgary-prd.yaml . -n alcyon-control-release --namespace alcyon-control > test.yaml

helm install --debug --dry-run -n alcyon-control-release --namespace alcyon-control  -f ../values-ca-calgary-prd-global.yaml -f values-ca-calgary-prd.yaml .

# To install
helm install alcyon-control-release --namespace alcyon-control  -f ../values-ca-calgary-prd-global.yaml -f values-ca-calgary-prd.yaml .

# To purge the release
helm uninstall -n alcyon-control alcyon-control-release

# To upgrade.
helm diff upgrade alcyon-control-release --namespace alcyon-control  -f ../values-ca-calgary-prd-global.yaml -f values-ca-calgary-prd.yaml .
# make sure only your changes are there then run
helm upgrade alcyon-control-release --namespace alcyon-control  -f ../values-ca-calgary-prd-global.yaml -f values-ca-calgary-prd.yaml .
````


### Calgary Chart

````
cd calgary-chart

kubectl create secret generic calgarytransformr-secret --from-literal=DB_PASSWORD=XXXXX --from-literal=CAL_SFTP_PASSWORD=XXXXX -n ca-calgary

helm template -f ../values-ca-calgary-prd-global.yaml  -f values-ca-calgary-prd.yaml . -n calgary-release --namespace ca-calgary > test.yaml

helm install --debug --dry-run -n calgary-release --namespace ca-calgary -f ../values-ca-calgary-prd-global.yaml  -f values-ca-calgary-prd.yaml .

# To install
helm install calgary-release --namespace ca-calgary -f ../values-ca-calgary-prd-global.yaml  -f values-ca-calgary-prd.yaml .

# To purge the release
helm uninstall -n ca-calgary calgary-release

# To upgrade.
helm diff upgrade calgary-release --namespace ca-calgary -f ../values-ca-calgary-prd-global.yaml  -f values-ca-calgary-prd.yaml .
# make sure only your changes are there then run
helm upgrade calgary-release --namespace ca-calgary -f ../values-ca-calgary-prd-global.yaml  -f values-ca-calgary-prd.yaml .
````

### Alcyon Chart

````
cd alcyon_chart

helm template . -n alcyon-release  -f ../values-ca-calgary-prd-global.yaml -f values-ca-calgary-prd.yaml --namespace alcyon-app > test.yaml

helm install --debug --dry-run alcyon-release -n alcyon-app  -f ../values-ca-calgary-prd-global.yaml -f values-ca-calgary-prd.yaml .

# To install
helm install alcyon-release -n alcyon-app  -f ../values-ca-calgary-prd-global.yaml -f values-ca-calgary-prd.yaml .

# To view diff before upgrade .
helm diff upgrade alcyon-release -n alcyon-app  -f ../values-ca-calgary-prd-global.yaml -f values-ca-calgary-prd.yaml .

# To upgrade the chart
helm upgrade alcyon-release -n alcyon-app  -f ../values-ca-calgary-prd-global.yaml -f values-ca-calgary-prd.yaml .

helm uninstall -n alcyon-app alcyon-release
````


## Troubleshooting

1. Network policy
until network policy is sorted for EKS, delete the policies to get the cluster working
````
kubectl delete networkpolicy --all --all-namespaces
````

2. If metrics show as unknown for any HPA and executing `kubectl describe apiservice v1beta1.metrics.k8s.io` command
   (after installing metrics server) shows similar message as below
```shell
failing or missing response from https://172.21.163.20:443/apis/metrics.k8s.io/v1beta1: Get "https://172.21.163.20:443/apis/metrics.k8s.io/v1beta1": Address is not allowed
```
then add `hostNetwork: true` to the `spec` key in `metrics-server` deployment and save to fix the issue
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
   labels:
      k8s-app: metrics-server
   name: metrics-server
   namespace: kube-system
spec:
   selector:
      matchLabels:
         k8s-app: metrics-server
   strategy:
      rollingUpdate:
         maxUnavailable: 0
   template:
      metadata:
         labels:
            k8s-app: metrics-server
      spec:
         hostNetwork: true
         containers:
            - args:
                 - --cert-dir=/tmp
                 - --secure-port=4443
                 - --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname
                 - --kubelet-use-node-status-port
              name: metrics-server
```
