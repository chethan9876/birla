# Helm chart installation instruction for Neo EKS cluster

## Cluster login Setup


1. Generate AWS credentials on your instance before running the container.

2. Run the kubernetes-tools container on your machine.
`docker run --rm -v "$HOME"/.aws:/root/.aws:ro -it docker.rtsprod.net/common/kubernetes-tools:1.18`

3. Setup Kubectl context 
`aws eks --region ap-southeast-2 update-kubeconfig --name nsw-prd-redflexnsw-onl-cluster --profile rms`
   

## Installation

1. Label the nodes
````
kubectl label node ip-10-33-4-117.ap-southeast-2.compute.internal node-role.kubernetes.io/worker=worker 
```` 

2. Setup namespaces

 NOTE: Calico policies work based on namespace labels. Adding labels are mandatory.
 
    ````
    kubectl create ns base
    kubectl label namespace/base name=base

    kubectl create ns monitoring
    kubectl label namespace/monitoring name=monitoring

    kubectl create ns alcyon-app 
    kubectl label namespace/alcyon-fs name=alcyon-app 
   
    kubectl create ns alcyon-fs 
    kubectl label namespace/alcyon-fs name=alcyon-fs 
   
    kubectl create ns utility 
    kubectl label namespace/utility name=utility 
    
    kubectl label namespace/default name=default 
    kubectl label namespace/kube-system name=kube-system  
    ````
     
3. Setup the image pull secret in all namespaces
    ````
    kubectl create secret docker-registry regsecret --docker-server=docker.rtsprod.net --docker-username=<username> --docker-password=<password> --docker-email=cst@redflex.com.au -n <namespace>
    
    #eg., 
    kubectl create secret docker-registry regsecret --docker-server=docker.rtsprod.net --docker-username=redflex --docker-password=XXX --docker-email=eng.support@redflex.com -n alcyon-fs 
    ```` 

## Deploy

### EKS chart

TODO: Fix the EKS chart and delete the backup files. This is NOT working currently.
````

# run following first time only:
kubectl annotate ConfigMap aws-auth -n kube-system meta.helm.sh/release-namespace=kube-system
kubectl annotate ConfigMap aws-auth -n kube-system meta.helm.sh/release-name=eks-release
kubectl label ConfigMap aws-auth -n kube-system app.kubernetes.io/managed-by=Helm
 
# To purge the release
helm uninstall -n base eks-release 

helm template eks-release -n kube-system -f ../values-au-nsw-prd-global.yaml -f values-au-nsw-prd.yaml . > test.yaml

# To install
helm install eks-release  --namespace kube-system  -f ../values-au-nsw-prd-global.yaml -f values-au-nsw-prd.yaml .


# To view diff before upgrade.
helm diff upgrade eks-release --namespace kube-system  -f ../values-au-nsw-prd-global.yaml -f values-au-nsw-prd.yaml .

# To upgrade the chart
helm upgrade eks-release --namespace kube-system  -f ../values-au-nsw-prd-global.yaml -f values-au-nsw-prd.yaml .

# To verify status
helm status eks-release --namespace kube-system
````

### Base chart

Prerequisite: AWS Subnets need to be tagged  with the following value to allow nginx-ingress to create ELB automatically.

For public subnet - `kubernetes.io/role/elb - 1`
For private subnet - `kubernetes.io/role/internal-elb - 1`
and cluster name should be tagged `kubernetes.io/cluster/nsw-dev-fs-redflexnsw-onl-cluster - shared`

````
 
# To purge the release
helm uninstall -n base base-release 

helm dependency update

helm template base-release -n base -f ../values-au-nsw-prd-global.yaml -f values-au-nsw-prd.yaml . > test.yaml

# To install
helm install base-release  --namespace base  -f ../values-au-nsw-prd-global.yaml -f values-au-nsw-prd.yaml .

# To view diff before upgrade.
helm diff upgrade base-release --namespace base -f ../values-au-nsw-prd-global.yaml -f values-au-nsw-prd.yaml .

# To upgrade the chart
helm upgrade base-release --namespace base -f ../values-au-nsw-prd-global.yaml -f values-au-nsw-prd.yaml .

# To verify status
helm status base-release
````

### Monitoring chart

````
kubectl create secret generic monitoring-secret --from-literal=GRAFANA_USER='XXX' --from-literal=GRAFANA_PASSWORD='XXXX' --from-literal=ES_PASSWORD='XXXX' -n monitoring

helm repo add kiwigrid https://kiwigrid.github.io  
helm dependency update

# To purge the release
helm uninstall -n monitoring monitoring-release 

helm template monitoring-release  -f ../values-au-nsw-prd-global.yaml -f values-au-nsw-prd.yaml -n monitoring . > test.yaml

# To install
helm install monitoring-release -n monitoring  -f ../values-au-nsw-prd-global.yaml -f values-au-nsw-prd.yaml .

helm diff upgrade monitoring-release -n monitoring   -f ../values-au-nsw-prd-global.yaml -f values-au-nsw-prd.yaml .

# To upgrade the chart when new subchart is added.
helm upgrade monitoring-release -n monitoring   -f ../values-au-nsw-prd-global.yaml -f values-au-nsw-prd.yaml .

# To verify status
helm status monitoring-release

helm uninstall -n <namespace> monitoring-release 
````

Once helm chart is deployed, follow the steps in monitoring-chart/README.md file.

### Alcyon Chart

You need to manually create alcyon-secret with the following keys:
- DB_PASSWORD
- DB_RO_PASSWORD
- ALCYON_SERVICE_PASSWORD
- ALCYON_PORTAL_PASSWORD

and s3-secret with the following keys:
- accesskey
- secretkey

Then use the following commands to set up the chart

````
cd alcyon_chart

kubectl create secret generic alcyon-secret --from-literal=DB_PASSWORD='XXXX' --from-literal=DB_RO_PASSWORD='XXXX' --from-literal=ALCYON_SERVICE_PASSWORD='XXXX' --from-literal=ALCYON_PORTAL_PASSWORD='XXXX' -n alcyon-app

# S3 secret for FieldService
kubectl create secret generic s3-secret --from-literal=accesskey='XXXX' --from-literal=secretkey='XXXX' -n alcyon-app

helm template . -n alcyon-release  -f ../values-au-nsw-prd-global.yaml -f values-au-nsw-prd.yaml --namespace alcyon-app > test.yaml

helm install --debug --dry-run alcyon-release -n alcyon-app  -f ../values-au-nsw-prd-global.yaml -f values-au-nsw-prd.yaml .

# To install
helm install alcyon-release -n alcyon-app  -f ../values-au-nsw-prd-global.yaml -f values-au-nsw-prd.yaml .

# To view diff before upgrade .
helm diff upgrade alcyon-release -n alcyon-app  -f ../values-au-nsw-prd-global.yaml -f values-au-nsw-prd.yaml .

# To upgrade the chart
helm upgrade alcyon-release -n alcyon-app  -f ../values-au-nsw-prd-global.yaml -f values-au-nsw-prd.yaml .

helm uninstall -n alcyon-app alcyon-release
````

## Alcyon Field Services Chart

You need to manually create alcyon-fs-secret with the following keys (refer to "create-secret.md"):
- DB_PASSWORD

Then use the following commands to set up the chart

````
cd field-service-chart
helm dependency update

kubectl create secret generic alcyon-secret --from-literal=DB_PASSWORD='XXXX' --from-literal=DB_RO_PASSWORD='XXXX' --from-literal=ALCYON_SERVICE_PASSWORD='XXXX' --from-literal=ALCYON_PORTAL_PASSWORD='XXXX' -n alcyon-fs
kubectl create secret generic alcyon-fs-secret --from-literal=DB_PASSWORD='XXXX' -n alcyon-fs

helm template . -n alcyon-fs-release  -f ../values-au-nsw-prd-global.yaml -f values-au-nsw-prd.yaml --namespace alcyon-fs > test.yaml

helm install --debug --dry-run alcyon-fs-release -n alcyon-fs  -f ../values-au-nsw-prd-global.yaml -f values-au-nsw-prd.yaml .

# To install
helm install alcyon-fs-release -n alcyon-fs  -f ../values-au-nsw-prd-global.yaml -f values-au-nsw-prd.yaml .

# To view diff before upgrade .
helm diff upgrade alcyon-fs-release -n alcyon-fs  -f ../values-au-nsw-prd-global.yaml -f values-au-nsw-prd.yaml .

# To upgrade the chart
helm upgrade alcyon-fs-release -n alcyon-fs  -f ../values-au-nsw-prd-global.yaml -f values-au-nsw-prd.yaml .

helm uninstall -n alcyon-fs alcyon-fs-release

````

## NSW Chart


You need to manually create nsw-secret with the following keys (refer to "create-secret.md"):
- ZINCR_ALCYON_REST_PASSWORD
- ZINCR_ITREE_PASSWORD
- ZINCR_EXPORT_PASSWORD

Then use the following commands to set up the chart

````
cd nsw-chart

kubectl create secret generic zincr-secret --from-literal=ZINCR_ALCYON_REST_PASSWORD='XXXX' --from-literal=ZINCR_ITREE_PASSWORD='XXXX' --from-literal=ZINCR_EXPORT_PASSWORD='XXXX' -n alcyon-app
kubectl create secret generic trafficstatsingestr-secret --from-literal=DB_PASSWORD='XXXX' -n alcyon-app

helm template . -n nsw-release  -f ../values-au-nsw-prd-global.yaml -f values-au-nsw-prd.yaml --namespace alcyon-app > test.yaml

helm install --debug --dry-run nsw-release -n alcyon-app  -f ../values-au-nsw-prd-global.yaml -f values-au-nsw-prd.yaml .

# To install
helm install nsw-release -n alcyon-app  -f ../values-au-nsw-prd-global.yaml -f values-au-nsw-prd.yaml .

# To view diff before upgrade .
helm diff upgrade nsw-release -n alcyon-app  -f ../values-au-nsw-prd-global.yaml -f values-au-nsw-prd.yaml .

# To upgrade the chart
helm upgrade nsw-release -n alcyon-app  -f ../values-au-nsw-prd-global.yaml -f values-au-nsw-prd.yaml .

helm uninstall -n alcyon-app nsw-release
````

## Utility Chart

Prerequisite: Create a Postgres Schema for Rundeck application.
> Refer to [Utility Readme file](utility-chart/README.md) for DB instructions.


````
cd utility-chart

kubectl create secret docker-registry regsecret --docker-server=dockerp.rtsprod.net --docker-username=redflex --docker-password=redflex --docker-email=cst@redflex.com -n utility
kubectl create secret generic utility-secret --from-literal=RUNDECK_DATABASE_PASSWORD='XXXX' --from-literal=RUNDECK_ALCYON_DB_PASSWORD='XXXX' --from-literal=RUNDECK_ALCYON_ADMIN_PASSWORD='XXXX' --from-literal=BIX_DB_PASSWORD='XXXX' --from-literal=TRAFFIC_STATS_DB_PASSWORD='XXXX' -n utility

helm repo add incubator http://storage.googleapis.com/kubernetes-charts-incubator  
helm dependency update

helm template  -f ../values-au-nsw-prd-global.yaml -f values-au-nsw-prd.yaml . -n utility-release --namespace utility > test.yaml

helm install --debug --dry-run -n utility-release --namespace utility  -f ../values-au-nsw-prd-global.yaml -f values-au-nsw-prd.yaml .

# To install
helm install utility-release --namespace utility  -f ../values-au-nsw-prd-global.yaml -f values-au-nsw-prd.yaml .

# To purge the release
helm uninstall -n utility utility-release

# To view diff before upgrade
helm diff upgrade utility-release --namespace utility  -f ../values-au-nsw-prd-global.yaml -f values-au-nsw-prd.yaml .

# To run upgrade.
helm upgrade utility-release --namespace utility  -f ../values-au-nsw-prd-global.yaml -f values-au-nsw-prd.yaml .

````

## Troubleshooting

1. Network policy
until network policy is sorted for EKS, delete the policies to get the cluster working
````
kubectl delete networkpolicy --all --all-namespaces
````
