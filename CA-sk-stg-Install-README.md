# Helm chart installation instruction for Saskatchewan Staging EKS cluster

## Cluster login Setup

1. Copy required files and folders using the sample command below
```shell
scp -r -J ec2-user@jumpbox.ca-sk-stg.redflexskca.onl <path to redflex-helm-charts>/<required file/folder> ec2-user@admin.ca-sk-stg.redflexskca.onl:/usr/share/redflex/redflex-helm-charts/<required file/folder>
```

2. SSH into admin box and exec into aws-kubernetes-tools container
```shell
ssh-add ~/.ssh/AWS_SKCA_STG_KeyPair.pem
ssh -J ec2-user@jumpbox.ca-sk-stg.redflexskca.onl ec2-user@admin.ca-sk-stg.redflexskca.onl
docker run -it --rm -v /usr/share/redflex/redflex-helm-charts:/data dockerp.rtsprod.net/common/aws-kubernetes-tools:latest
#In the container bash run the following command to generate the aws key
gimme-aws-creds --profile ca-sk
#Export the EKS kubeconfig
export AWS_REGION=ca-central-1
aws eks update-kubeconfig --name stg-ca-sk-eks --profile ca-sk
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

kubectl create ns alcyon-app 
kubectl label namespace/alcyon-app name=alcyon-app

kubectl create ns stub  
kubectl label namespace/stub name=stub

kubectl create ns ca-sk 
kubectl label namespace/ca-sk name=ca-sk

kubectl label namespace/default name=default 
kubectl label namespace/kube-system name=kube-system
````
     
3. Setup the image pull secret in all namespaces
````
kubectl create secret docker-registry regsecret --docker-server=dockerp.rtsprod.net --docker-username=<username> --docker-password=<password> --docker-email=cst@redflex.com.au -n <namespace>

#eg., 
kubectl create secret docker-registry regsecret --docker-server=dockerp.rtsprod.net --docker-username=redflex --docker-password=redflex --docker-email=eng.support@redflex.com -n alcyon-app
kubectl create secret docker-registry regsecret --docker-server=dockerp.rtsprod.net --docker-username=redflex --docker-password=redflex --docker-email=eng.support@redflex.com -n alcyon-fs
kubectl create secret docker-registry regsecret --docker-server=dockerp.rtsprod.net --docker-username=redflex --docker-password=redflex --docker-email=eng.support@redflex.com -n ca-sk
kubectl create secret docker-registry regsecret --docker-server=dockerp.rtsprod.net --docker-username=redflex --docker-password=redflex --docker-email=eng.support@redflex.com -n utility
kubectl create secret docker-registry regsecret --docker-server=dockerp.rtsprod.net --docker-username=redflex --docker-password=redflex --docker-email=eng.support@redflex.com -n stub
```` 

## Deploy

### EKS chart

````

# run following first time only:
kubectl annotate ConfigMap aws-auth -n kube-system meta.helm.sh/release-namespace=kube-system
kubectl annotate ConfigMap aws-auth -n kube-system meta.helm.sh/release-name=eks-release
kubectl label ConfigMap aws-auth -n kube-system app.kubernetes.io/managed-by=Helm\

# To purge the release
helm uninstall -n kube-system eks-release 

helm template eks-release -n kube-system -f ../values-ca-sk-stg-global.yaml -f values-ca-sk-stg.yaml . > test.yaml

# To install
helm install eks-release  --namespace kube-system -f ../values-ca-sk-stg-global.yaml -f values-ca-sk-stg.yaml .

# To upgrade the chart
helm diff upgrade eks-release --namespace kube-system -f ../values-ca-sk-stg-global.yaml -f values-ca-sk-stg.yaml .
# make sure only your changes are there then run
helm upgrade eks-release --namespace kube-system -f ../values-ca-sk-stg-global.yaml -f values-ca-sk-stg.yaml .

# To verify status
helm status eks-release -n kube-system 
````

### Base chart

````

# To purge the release
helm uninstall -n base base-release 

helm dependency update

helm template base-release -n base -f ../values-ca-sk-stg-global.yaml -f values-ca-sk-stg.yaml . > test.yaml

# To install
helm install base-release  --namespace base  -f ../values-ca-sk-stg-global.yaml -f values-ca-sk-stg.yaml .

# To view diff before upgrade.
helm diff upgrade base-release --namespace base -f ../values-ca-sk-stg-global.yaml -f values-ca-sk-stg.yaml .

# To upgrade the chart
helm upgrade base-release --namespace base -f ../values-ca-sk-stg-global.yaml -f values-ca-sk-stg.yaml .

# To verify status
helm status base-release
````

### Monitoring chart

````
kubectl create secret generic monitoring-secret --from-literal=GRAFANA_USER='XXX' --from-literal=GRAFANA_PASSWORD='XXXX' -n monitoring

helm repo add kiwigrid https://kiwigrid.github.io  
helm dependency update

# To purge the release
helm uninstall -n monitoring monitoring-release 

helm template monitoring-release  -f ../values-ca-sk-stg-global.yaml -f values-ca-sk-stg.yaml -n monitoring . > test.yaml

# To install
helm install monitoring-release -n monitoring  -f ../values-ca-sk-stg-global.yaml -f values-ca-sk-stg.yaml .

helm diff upgrade monitoring-release -n monitoring   -f ../values-ca-sk-stg-global.yaml -f values-ca-sk-stg.yaml .

# To upgrade the chart when new subchart is added.
helm upgrade monitoring-release -n monitoring   -f ../values-ca-sk-stg-global.yaml -f values-ca-sk-stg.yaml .

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

helm template  -f ../values-ca-sk-stg-global.yaml -f values-ca-sk-stg.yaml . -n utility-release --namespace utility > test.yaml

helm install --debug --dry-run utility-release --namespace utility  -f ../values-ca-sk-stg-global.yaml -f values-ca-sk-stg.yaml .

# To install
helm install utility-release --namespace utility  -f ../values-ca-sk-stg-global.yaml -f values-ca-sk-stg.yaml .

# To purge the release
helm uninstall -n utility utility-release

# To view diff before upgrade
helm diff upgrade utility-release --namespace utility  -f ../values-ca-sk-stg-global.yaml -f values-ca-sk-stg.yaml .

# To run upgrade.
helm upgrade utility-release --namespace utility  -f ../values-ca-sk-stg-global.yaml -f values-ca-sk-stg.yaml .

````

### Alcyon Chart

````
cd alcyon_chart

kubectl create secret generic alcyon-secret --from-literal=DB_PASSWORD='XXXX' --from-literal=DB_RO_PASSWORD='XXXX' --from-literal=ALCYON_SERVICE_PASSWORD='XXXX' --from-literal=ALCYON_PORTAL_PASSWORD='XXXX' --from-literal=KAFKA_PASSWORD='XXXX' -n alcyon-app

# S3 secret for FieldService
kubectl create secret generic s3-secret --from-literal=accesskey='XXXX' --from-literal=secretkey='XXXX' -n alcyon-app

helm template . -n alcyon-release  -f ../values-ca-sk-stg-global.yaml -f values-ca-sk-stg.yaml --namespace alcyon-app > test.yaml

helm install --debug --dry-run alcyon-release -n alcyon-app  -f ../values-ca-sk-stg-global.yaml -f values-ca-sk-stg.yaml .

# To install
helm install alcyon-release -n alcyon-app  -f ../values-ca-sk-stg-global.yaml -f values-ca-sk-stg.yaml .

# To view diff before upgrade .
helm diff upgrade alcyon-release -n alcyon-app  -f ../values-ca-sk-stg-global.yaml -f values-ca-sk-stg.yaml .

# To upgrade the chart
helm upgrade alcyon-release -n alcyon-app  -f ../values-ca-sk-stg-global.yaml -f values-ca-sk-stg.yaml .

helm uninstall -n alcyon-app alcyon-release
````

### CA-SK Chart

````
cd ca-sk-chart

kubectl create secret generic ca-sk-secret --from-literal=SEEKR_PASSWORD='XXXX' --from-literal=LEDGR_PASSWORD='XXXX' --from-literal=CALLBACK_PASSWORD="XXXX" --from-literal=ALCYON_SERVICE_PASSWORD='XXXX' --from-literal=ALCYON_PORTAL_PASSWORD='XXXX' -n ca-sk

kubectl create secret generic recaptcha-secret --from-literal=sitekey='XXXX' --from-literal=secretkey='XXXX' -n ca-sk

kubectl create secret generic s3-secret --from-literal=accesskey='XXXX' --from-literal=secretkey='XXXX' -n ca-sk

helm template -f ../values-ca-sk-stg-global.yaml  -f values-ca-sk-stg.yaml . -n ca-sk-release --namespace ca-sk > test.yaml

helm install --debug --dry-run ca-sk-release --namespace ca-sk -f ../values-ca-sk-stg-global.yaml  -f values-ca-sk-stg.yaml .

# To install
helm install ca-sk-release --namespace ca-sk -f ../values-ca-sk-stg-global.yaml  -f values-ca-sk-stg.yaml .

# To purge the release
helm uninstall -n ca-sk ca-sk-release

# To upgrade.
helm diff upgrade ca-sk-release --namespace ca-sk -f ../values-ca-sk-stg-global.yaml  -f values-ca-sk-stg.yaml .
# make sure only your changes are there then run
helm upgrade ca-sk-release --namespace ca-sk -f ../values-ca-sk-stg-global.yaml  -f values-ca-sk-stg.yaml .
````

## Stub Chart

````
cd stub-chart

helm template  -f ../values-ca-sk-stg-global.yaml -f values-ca-sk-stg.yaml . -n stub-release --namespace stub > test.yaml

helm install --debug --dry-run stub-release --namespace stub  -f ../values-ca-sk-stg-global.yaml -f values-ca-sk-stg.yaml .

# To install
helm install stub-release --namespace stub  -f ../values-ca-sk-stg-global.yaml -f values-ca-sk-stg.yaml .

# To purge the release
helm uninstall -n stub stub-release

# To run upgrade.
helm diff upgrade stub-release --namespace stub  -f ../values-ca-sk-stg-global.yaml -f values-ca-sk-stg.yaml .
# make sure only your changes are there then run
helm upgrade stub-release --namespace stub  -f ../values-ca-sk-stg-global.yaml -f values-ca-sk-stg.yaml .

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
