# Helm chart installation instruction for AU-NT EKS cluster
## Cluster login setup

1. Run the kubernetes-tools container on the admin box.
`docker run -it --rm -v /usr/share/redflex/redflex-helm-charts/:/data/ dockerp.rtsprod.net/common/aws-kubernetes-tools:latest`

2. Setup Kubectl context
`aws eks --region ap-southeast-2 update-kubeconfig --name prd-au-nt-eks --profile au-nt`

3. In case you need a public IP you can run this from command line:
`curl -s https://www.icanhazip.com/`
## Instalation


1. Setup namespaces

NOTE: Calico policies work based on namespace labels. Adding labels are mandatory.

````
kubectl create ns base
kubectl label namespace/base name=base

kubectl create ns monitoring
kubectl label namespace/monitoring name=monitoring

kubectl create ns alcyon-app
kubectl label namespace/alcyon-app name=alcyon-app

kubectl create ns utility
kubectl label namespace/utility name=utility

kubectl create ns migration
kubectl label namespace/migration name=migration

kubectl create ns arm
kubectl label namespace/arm name=arm

kubectl create ns au-nt
kubectl label namespace/au-nt name=au-nt

kubectl label namespace/default name=default
kubectl label namespace/kube-system name=kube-system
````

2. Setup the image pull secret in all namespaces
````
kubectl create secret docker-registry regsecret --docker-server=docker.rtsprod.net --docker-username=<username> --docker-password=<password> --docker-email=cst@redflex.com.au -n <namespace>

#eg.,
kubectl create secret docker-registry regsecret --docker-server=dockerp.rtsprod.net --docker-username=redflex --docker-password=redflex --docker-email=cst@redflex.com -n alcyon-app
kubectl create secret docker-registry regsecret --docker-server=dockerp.rtsprod.net --docker-username=redflex --docker-password=redflex --docker-email=cst@redflex.com -n au-nt
kubectl create secret docker-registry regsecret --docker-server=dockerp.rtsprod.net --docker-username=redflex --docker-password=redflex --docker-email=cst@redflex.com -n arm
kubectl create secret docker-registry regsecret --docker-server=dockerp.rtsprod.net --docker-username=redflex --docker-password=redflex --docker-email=cst@redflex.com -n migration
kubectl create secret docker-registry regsecret --docker-server=dockerp.rtsprod.net --docker-username=redflex --docker-password=redflex --docker-email=cst@redflex.com -n utility
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

helm template eks-release -n kube-system -f ../values-prd-au-nt-global.yaml -f values-prd-au-nt.yaml . > test.yaml

# To install
helm install eks-release  --namespace kube-system  -f ../values-prd-au-nt-global.yaml -f values-prd-au-nt.yaml .


# To upgrade the chart
helm diff upgrade eks-release --namespace kube-system  -f ../values-prd-au-nt-global.yaml -f values-prd-au-nt.yaml .
# make sure only your changes are there then run
helm upgrade eks-release --namespace kube-system  -f ../values-prd-au-nt-global.yaml -f values-prd-au-nt.yaml .

# To verify status
helm status eks-release -n kube-system
````

### Base chart

Prerequisite: AWS Subnets need to be tagged  with the following value to allow nginx-ingress to create ELB automatically.

For public subnet - `kubernetes.io/role/elb - 1`
For private subnet - `kubernetes.io/role/internal-elb - 1`
and cluster name should be tagged `kubernetes.io/cluster/neo-rts-onl-cluster - shared`

````

# To purge the release
helm uninstall -n base base-release

helm dependency update

helm template base-release -n base -f ../values-prd-au-nt-global.yaml -f values-prd-au-nt.yaml . > test.yaml

# To install
helm install base-release  --namespace base  -f ../values-prd-au-nt-global.yaml -f values-prd-au-nt.yaml .

# To upgrade the chart.
helm diff upgrade base-release --namespace base -f ../values-prd-au-nt-global.yaml -f values-prd-au-nt.yaml .
# make sure only your changes are there then run
helm upgrade base-release --namespace base -f ../values-prd-au-nt-global.yaml -f values-prd-au-nt.yaml .

# To verify status
helm status base-release
````

### Monitoring chart

````
helm repo add kiwigrid https://kiwigrid.github.io
helm repo add grafana https://grafana.github.io/helm-charts
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add nri-bundle https://helm-charts.newrelic.com

# Run this prior to install, required for nri-bundle (new-relic)
# update requirements yaml to have nri-bundle version to 5.0.11

helm dependency update

# To purge the release
helm uninstall -n monitoring monitoring-release

helm template monitoring-release  -f ../values-prd-au-nt-global.yaml -f values-prd-au-nt.yaml -n monitoring . > test.yaml

# To install
helm install monitoring-release -n monitoring  -f ../values-prd-au-nt-global.yaml -f values-prd-au-nt.yaml .

# To upgrade the chart when new subchart is added.
helm diff upgrade monitoring-release -n monitoring   -f ../values-prd-au-nt-global.yaml -f values-prd-au-nt.yaml .
# make sure only your changes are there then run
helm upgrade monitoring-release -n monitoring   -f ../values-prd-au-nt-global.yaml -f values-prd-au-nt.yaml .

# To verify status
helm status monitoring-release

kubectl delete crd  viziers.px.dev
helm uninstall -n monitoring monitoring-release
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

kubectl create secret generic alcyon-secret --from-literal=DB_PASSWORD='XXXX' --from-literal=DB_RO_PASSWORD='XXXX' --from-literal=ALCYON_SERVICE_PASSWORD='XXXX' --from-literal=ALCYON_PORTAL_PASSWORD='XXXX' --from-literal=KAFKA_PASSWORD='XXXX' -n au-wa

# S3 secret for FieldService
kubectl create secret generic s3-secret --from-literal=accesskey='XXXX' --from-literal=secretkey='XXXX' -n alcyon-app
# archive secret
kubectl create secret generic archive-secret --from-literal=accesskey='XXXX' --from-literal=secretkey='XXXX' -n alcyon-app

helm template . -n alcyon-release  -f ../values-prd-au-nt-global.yaml -f values-prd-au-nt.yaml --namespace alcyon-app > test.yaml

helm install --debug --dry-run alcyon-release -n alcyon-app  -f ../values-prd-au-nt-global.yaml -f values-prd-au-nt.yaml .

# To install
helm install alcyon-release -n alcyon-app  -f ../values-prd-au-nt-global.yaml -f values-prd-au-nt.yaml .

# To upgrade the chart
helm diff upgrade alcyon-release -n alcyon-app  -f ../values-prd-au-nt-global.yaml -f values-prd-au-nt.yaml .
# make sure only your changes are there then run
helm upgrade alcyon-release -n alcyon-app  -f ../values-prd-au-nt-global.yaml -f values-prd-au-nt.yaml .

helm uninstall -n alcyon-app alcyon-release
````

### au-nt Chart

````
cd au-nt-chart

# S3 secret for au-wa charts
kubectl create secret generic s3-secret --from-literal  =accesskey='XXXX' --from-literal=secretkey='XXXX' -n au-nt

helm template . -n au-nt-release  -f ../values-prd-au-nt-global.yaml -f values-prd-au-nt.yaml --namespace alcyon-app > test.yaml

helm install --debug --dry-run au-nt-release -n au-nt  -f ../values-prd-au-nt-global.yaml -f values-prd-au-nt.yaml .

# To install
helm install au-nt-release -n au-nt  -f ../values-prd-au-nt-global.yaml -f values-prd-au-nt.yaml .

# To upgrade the chart
helm diff upgrade au-nt-release -n au-nt  -f ../values-prd-au-nt-global.yaml -f values-prd-au-nt.yaml .
# make sure only your changes are there then run
helm upgrade au-nt-release -n au-nt  -f ../values-prd-au-nt-global.yaml -f values-prd-au-nt.yaml .

helm uninstall -n au-nt au-nt-release
````

## Utility Chart

Prerequisite: Create a Postgres Schema for Rundeck application.
> Refer to [Utility Readme file](utility-chart/README.md) for DB instructions.


````
cd utility-chart

kubectl create secret generic utility-secret --from-literal=RUNDECK_DATABASE_PASSWORD='XXXX' --from-literal=RUNDECK_ALCYON_DB_PASSWORD='XXXX' --from-literal=RUNDECK_ALCYON_ADMIN_PASSWORD='XXXX' --from-literal=BIX_DB_PASSWORD='XXXX' --from-literal=TRAFFIC_STATS_DB_PASSWORD='XXXX' -n utility

helm repo add incubator http://storage.googleapis.com/kubernetes-charts-incubator
helm dependency update

helm template  -f ../values-prd-au-nt-global.yaml -f values-prd-au-nt.yaml . -n utility-release --namespace utility > test.yaml

helm install --debug --dry-run utility-release --namespace utility  -f ../values-prd-au-nt-global.yaml -f values-prd-au-nt.yaml .

# To install
helm install utility-release --namespace utility  -f ../values-prd-au-nt-global.yaml -f values-prd-au-nt.yaml .

# To purge the release
helm uninstall -n utility utility-release

# To run upgrade.
helm diff upgrade utility-release --namespace utility  -f ../values-prd-au-nt-global.yaml -f values-prd-au-nt.yaml .
# make sure only your changes are there then run
helm upgrade utility-release --namespace utility  -f ../values-prd-au-nt-global.yaml -f values-prd-au-nt.yaml .

````


## Migration Chart

````
cd migration-chart

kubectl create secret generic mongo-secret --from-literal=MONGO_PASSWORD='XXXX' -n migration
kubectl create secret generic migration-secret --from-literal=ORACLE_PASSWORD='XXXX' --from-literal=ALCYON_SERVICE_PASSWORD='XXXX' --from-literal=SIDEKIQ_USERNAME='XXXX' --from-literal=SIDEKIQ_PASSWORD='XXXX' -n migration

helm template -f ../values-prd-au-nt-global.yaml  -f values-prd-au-nt.yaml . -n migration-release --namespace migration > test.yaml

helm install --debug --dry-run -n migration-release --namespace migration -f ../values-prd-au-nt-global.yaml  -f values-prd-au-nt.yaml .

# To install
helm install migration-release --namespace migration -f ../values-prd-au-nt-global.yaml  -f values-prd-au-nt.yaml .

# To purge the release
helm uninstall -n migration migration-release

# To run upgrade.
helm diff upgrade migration-release --namespace migration -f ../values-prd-au-nt-global.yaml  -f values-prd-au-nt.yaml .
# make sure only your changes are there then run
helm upgrade migration-release --namespace migration -f ../values-prd-au-nt-global.yaml  -f values-prd-au-nt.yaml .

````

## ARM Chart

````
cd arm-chart

kubectl create secret docker-registry regsecret --docker-server=docker.rtsprod.net  --docker-username=redflex --docker-password=XXX --docker-email=cst@redflex.com -n arm
kubectl create secret generic arm-secret --from-literal=DATASOURCE_PASSWORD='XXXX' -n arm

helm template  -f ../values-prd-au-nt-global.yaml -f values-prd-au-nt.yaml . -n arm-release --namespace arm > test.yaml

helm install --debug --dry-run -n arm-release --namespace arm  -f ../values-prd-au-nt-global.yaml -f values-prd-au-nt.yaml .

# To install
helm install arm-release --namespace arm  -f ../values-prd-au-nt-global.yaml -f values-prd-au-nt.yaml .

# To purge the release
helm uninstall -n arm arm-release

# To run upgrade.
helm diff upgrade arm-release --namespace arm  -f ../values-prd-au-nt-global.yaml -f values-prd-au-nt.yaml .
# make sure only your changes are there then run
helm upgrade arm-release --namespace arm  -f ../values-prd-au-nt-global.yaml -f values-prd-au-nt.yaml .

````