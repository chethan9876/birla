# Helm chart installation instruction for prd-nz-wk-eks cluster
## Cluster login setup

1. Run the kubernetes-tools container on the admin box.
`docker run -it --rm -v /usr/share/redflex/redflex-helm-charts/:/data/ dockerp.rtsprod.net/common/aws-kubernetes-tools:latest`

2. Setup Kubectl context
`aws eks --region ap-southeast-2 update-kubeconfig --name prd-nz-wk-eks --profile nz-wk`

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

kubectl create ns alcyon-control
kubectl label namespace/alcyon-control name=alcyon-control

kubectl create ns stub
kubectl label namespace/stub name=stub

kubectl create ns nz-wk
kubectl label namespace/nz-wk name=nz-wk

kubectl create ns alcyon-control
kubectl label namespace/alcyon-control name=alcyon-control

kubectl create ns alcyon-express
kubectl label namespace/alcyon-express name=alcyon-express

kubectl label namespace/default name=default
kubectl label namespace/kube-system name=kube-system
````

2. Setup the image pull secret in all namespaces
````
kubectl create secret docker-registry regsecret --docker-server=docker.rtsprod.net --docker-username=<username> --docker-password=<password> --docker-email=cst@redflex.com.au -n <namespace>

#eg.,
kubectl create secret docker-registry regsecret --docker-server=dockerp.rtsprod.net --docker-username=redflex --docker-password=redflex --docker-email=cst@redflex.com -n alcyon-control
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

helm template eks-release -n kube-system -f ../values-prd-nz-wk-global.yaml -f values-prd-nz-wk.yaml . > test.yaml

# To install
helm install eks-release  --namespace kube-system  -f ../values-prd-nz-wk-global.yaml -f values-prd-nz-wk.yaml .


# To upgrade the chart
helm diff upgrade eks-release --namespace kube-system  -f ../values-prd-nz-wk-global.yaml -f values-prd-nz-wk.yaml .
# make sure only your changes are there then run
helm upgrade eks-release --namespace kube-system  -f ../values-prd-nz-wk-global.yaml -f values-prd-nz-wk.yaml .

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

helm template base-release -n base -f ../values-prd-nz-wk-global.yaml -f values-prd-nz-wk.yaml . > test.yaml

# To install
helm install base-release  --namespace base  -f ../values-prd-nz-wk-global.yaml -f values-prd-nz-wk.yaml .

# To upgrade the chart.
helm diff upgrade base-release --namespace base -f ../values-prd-nz-wk-global.yaml -f values-prd-nz-wk.yaml .
# make sure only your changes are there then run
helm upgrade base-release --namespace base -f ../values-prd-nz-wk-global.yaml -f values-prd-nz-wk.yaml .

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

helm template monitoring-release  -f ../values-prd-nz-wk-global.yaml -f values-prd-nz-wk.yaml -n monitoring . > test.yaml

# To install
helm install monitoring-release -n monitoring  -f ../values-prd-nz-wk-global.yaml -f values-prd-nz-wk.yaml .

# To upgrade the chart when new subchart is added.
helm diff upgrade monitoring-release -n monitoring   -f ../values-prd-nz-wk-global.yaml -f values-prd-nz-wk.yaml .
# make sure only your changes are there then run
helm upgrade monitoring-release -n monitoring   -f ../values-prd-nz-wk-global.yaml -f values-prd-nz-wk.yaml .

# To verify status
helm status monitoring-release

kubectl delete crd  viziers.px.dev
helm uninstall -n monitoring monitoring-release
````

Once helm chart is deployed, follow the steps in monitoring-chart/README.md file.

## Alcyon Control Chart

````
cd alcyon-control-chart
helm dependency update

kubectl create secret generic alcyon-control-secret --from-literal=GOVERNR_DB_PASSWORD='XXXX' -n alcyon-control

helm template -f ../values-uat-nz-wk-global.yaml -f values-uat-nz-wk.yaml . -n alcyon-control-release --namespace alcyon-control > test.yaml

helm install --debug --dry-run -n alcyon-control-release --namespace alcyon-control  -f ../values-prd-nz-wk-global.yaml -f values-prd-nz-wk.yaml .

# To install
helm install alcyon-control-release --namespace alcyon-control  -f ../values-prd-nz-wk-global.yaml -f values-prd-nz-wk.yaml .

# To purge the release
helm uninstall -n alcyon-control alcyon-control-release

# To upgrade.
helm diff upgrade alcyon-control-release --namespace alcyon-control  -f ../values-prd-nz-wk-global.yaml -f values-prd-nz-wk.yaml .
# make sure only your changes are there then run
helm upgrade alcyon-control-release --namespace alcyon-control  -f ../values-prd-nz-wk-global.yaml -f values-prd-nz-wk.yaml .
````
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

kubectl create secret generic alcyon-secret --from-literal=DB_PASSWORD='XXXX' --from-literal=DB_RO_PASSWORD='XXXX' --from-literal=ALCYON_SERVICE_PASSWORD='XXXX' --from-literal=ALCYON_PORTAL_PASSWORD='XXXX' --from-literal=KAFKA_PASSWORD='XXXX' -n alcyon-app

# S3 secret for FieldService
kubectl create secret generic s3-secret --from-literal=accesskey='XXXX' --from-literal=secretkey='XXXX' -n alcyon-app
# archive secret
kubectl create secret generic archive-secret --from-literal=accesskey='XXXX' --from-literal=secretkey='XXXX' -n alcyon-app

helm template . -n alcyon-release  -f ../values-prd-nz-wk-global.yaml -f values-prd-nz-wk.yaml --namespace alcyon-app > test.yaml

helm install --debug --dry-run alcyon-release -n alcyon-app  -f ../values-prd-nz-wk-global.yaml -f values-prd-nz-wk.yaml .

# To install
helm install alcyon-release -n alcyon-app  -f ../values-prd-nz-wk-global.yaml -f values-prd-nz-wk.yaml .

# To upgrade the chart
helm diff upgrade alcyon-release -n alcyon-app  -f ../values-prd-nz-wk-global.yaml -f values-prd-nz-wk.yaml .
# make sure only your changes are there then run
helm upgrade alcyon-release -n alcyon-app  -f ../values-prd-nz-wk-global.yaml -f values-prd-nz-wk.yaml .

helm uninstall -n alcyon-app alcyon-release
````
-----------------------------------------------------------------------------------------------------------------------
## Utility Chart

Prerequisite: Create a Postgres Schema for Rundeck application.
> Refer to [Utility Readme file](utility-chart/README.md) for DB instructions.


````
cd utility-chart

kubectl create secret generic utility-secret --from-literal=RUNDECK_DATABASE_PASSWORD='XXXX' --from-literal=RUNDECK_ALCYON_DB_PASSWORD='XXXX' --from-literal=RUNDECK_ALCYON_ADMIN_PASSWORD='XXXX' --from-literal=BIX_DB_PASSWORD='XXXX' --from-literal=TRAFFIC_STATS_DB_PASSWORD='XXXX' -n utility

helm repo add incubator http://storage.googleapis.com/kubernetes-charts-incubator
helm dependency update

helm template  -f ../values-prd-nz-wk-global.yaml -f values-prd-nz-wk.yaml . -n utility-release --namespace utility > test.yaml

helm install --debug --dry-run utility-release --namespace utility  -f ../values-prd-nz-wk-global.yaml -f values-prd-nz-wk.yaml .

# To install
helm install utility-release --namespace utility  -f ../values-prd-nz-wk-global.yaml -f values-prd-nz-wk.yaml .

# To purge the release
helm uninstall -n utility utility-release

# To run upgrade.
helm diff upgrade utility-release --namespace utility  -f ../values-prd-nz-wk-global.yaml -f values-prd-nz-wk.yaml .
# make sure only your changes are there then run
helm upgrade utility-release --namespace utility  -f ../values-prd-nz-wk-global.yaml -f values-prd-nz-wk.yaml .

````
................................................................................................................
## Stub Chart

````
cd /data/stub-chart

kubectl create secret docker-registry regsecret --docker-server=dockerp.rtsprod.net  --docker-username=redflex --docker-password=XXX --docker-email=cst@redflex.com -n stub

helm template  -f ../values-stg-nz-wk-global.yaml -f values-stg-nz-wk.yaml . -n stub-release --namespace stub > test.yaml

helm install --debug --dry-run  stub-release --namespace stub  -f ../values-prd-nz-wk-global.yaml -f values-prd-nz-wk.yaml .

# To install
helm install stub-release --namespace stub  -f ../values-prd-nz-wk-global.yaml -f values-prd-nz-wk.yaml .

# To purge the release
helm uninstall -n stub stub-release

# To run upgrade.
helm diff upgrade stub-release --namespace stub  -f ../values-prd-nz-wk-global.yaml -f values-prd-nz-wk.yaml .
# make sure only your changes are there then run
helm upgrade stub-release --namespace stub  -f ../values-prd-nz-wk-global.yaml -f values-prd-nz-wk.yaml .

````
