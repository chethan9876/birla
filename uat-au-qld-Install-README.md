# Helm chart installation instruction for au-qld EKS cluster

## Cluster login setup

1. Run the kubernetes-tools container on the admin box.
`docker run -it --rm -v /usr/share/redflex/redflex-helm-charts/:/data/ dockerp.rtsprod.net/common/aws-kubernetes-tools:latest`

2. Setup Kubectl context 
`aws eks --region ap-southeast-2 update-kubeconfig --name uat-au-qld-eks --profile au-qld`

3. In case you need a public IP you can run this from command line:
`curl -s https://www.showmyip.com/ | grep -oPm1 "(?<=<h2 id=\"ipv4\">)[^<]+"`
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

kubectl create ns stub 
kubectl label namespace/stub name=stub 

kubectl create ns au-qld
kubectl label namespace/au-qld name=au-qld

kubectl label namespace/default name=default 
kubectl label namespace/kube-system name=kube-system
````
     
2. Setup the image pull secret in all namespaces
````
kubectl create secret docker-registry regsecret --docker-server=docker.rtsprod.net --docker-username=<username> --docker-password=<password> --docker-email=cst@redflex.com.au -n <namespace>

#eg., 
kubectl create secret docker-registry regsecret --docker-server=dockerp.rtsprod.net --docker-username=redflex --docker-password=XXX --docker-email=cst@redflex.com -n alcyon-app
kubectl create secret docker-registry regsecret --docker-server=dockerp.rtsprod.net --docker-username=redflex --docker-password=XXX  --docker-email=cst@redflex.com -n monitoring
kubectl create secret docker-registry regsecret --docker-server=dockerp.rtsprod.net --docker-username=redflex --docker-password=XXX  --docker-email=cst@redflex.com -n au-qld
kubectl create secret docker-registry regsecret --docker-server=dockerp.rtsprod.net --docker-username=redflex --docker-password=XXX  --docker-email=cst@redflex.com -n arm
kubectl create secret docker-registry regsecret --docker-server=dockerp.rtsprod.net --docker-username=redflex --docker-password=XXX  --docker-email=cst@redflex.com -n migration
kubectl create secret docker-registry regsecret --docker-server=dockerp.rtsprod.net --docker-username=redflex --docker-password=XXX  --docker-email=cst@redflex.com -n utility
kubectl create secret docker-registry regsecret --docker-server=dockerp.rtsprod.net --docker-username=redflex --docker-password=XXX  --docker-email=cst@redflex.com -n stub
```` 

## Deploy

### EKS chart (Cross-check before you run it otherwise you will loose access to the cluster)

````
# run following first time only:
kubectl annotate ConfigMap aws-auth -n kube-system meta.helm.sh/release-namespace=kube-system
kubectl annotate ConfigMap aws-auth -n kube-system meta.helm.sh/release-name=eks-release
kubectl label ConfigMap aws-auth -n kube-system app.kubernetes.io/managed-by=Helm

# To purge the release
helm uninstall -n kube-system eks-release 

helm template eks-release -n kube-system -f ../values-uat-au-qld-global.yaml -f values-uat-au-qld.yaml . > test.yaml

# To install
helm install eks-release  --namespace kube-system  -f ../values-uat-au-qld-global.yaml -f values-uat-au-qld.yaml .


# To upgrade the chart
helm diff upgrade eks-release --namespace kube-system  -f ../values-uat-au-qld-global.yaml -f values-uat-au-qld.yaml .
# make sure only your changes are there then run
helm upgrade eks-release --namespace kube-system  -f ../values-uat-au-qld-global.yaml -f values-uat-au-qld.yaml .

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

helm repo add  alb https://aws.github.io/eks-charts
helm dependency update
kubectl apply -k "github.com/aws/eks-charts/stable/aws-load-balancer-controller/crds?ref=master"

helm template base-release -n base -f ../values-uat-au-qld-global.yaml -f values-uat-au-qld.yaml . > test.yaml

# To install
helm install base-release  --namespace base  -f ../values-uat-au-qld-global.yaml -f values-uat-au-qld.yaml .

# To upgrade the chart.
helm diff upgrade base-release --namespace base -f ../values-uat-au-qld-global.yaml -f values-uat-au-qld.yaml .
# make sure only your changes are there then run
helm upgrade base-release --namespace base -f ../values-uat-au-qld-global.yaml -f values-uat-au-qld.yaml .

# To verify status
helm status base-release
````
    
### Monitoring chart

````
kubectl create secret generic monitoring-secret --from-literal=GRAFANA_USER='XXX' --from-literal=GRAFANA_PASSWORD='XXXX' --from-literal=ES_PASSWORD='XXXX' -n monitoring

helm repo add kiwigrid https://kiwigrid.github.io
helm repo add grafana https://grafana.github.io/helm-charts  
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add nri-bundle helm-charts.newrelic.com

# Run this prior to install, required for nri-bundle (new-relic)
kubectl apply -f https://raw.githubusercontent.com/pixie-labs/pixie/main/k8s/operator/crd/base/px.dev_viziers.yaml
kubectl apply -f https://raw.githubusercontent.com/pixie-labs/pixie/main/k8s/operator/helm/crds/olm_crd.yaml
  
helm dependency update

# To purge the release
helm uninstall -n monitoring monitoring-release 

helm template monitoring-release  -f ../values-uat-au-qld-global.yaml -f values-uat-au-qld.yaml -n monitoring . > test.yaml

# To install
helm install monitoring-release -n monitoring  -f ../values-uat-au-qld-global.yaml -f values-uat-au-qld.yaml .

# To upgrade the chart when new subchart is added.
helm diff upgrade monitoring-release -n monitoring   -f ../values-uat-au-qld-global.yaml -f values-uat-au-qld.yaml .
# make sure only your changes are there then run
helm upgrade monitoring-release -n monitoring   -f ../values-uat-au-qld-global.yaml -f values-uat-au-qld.yaml .

# To verify status
helm status monitoring-release -n monitoring

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

kubectl create secret generic alcyon-secret --from-literal=DB_PASSWORD='XXXX' --from-literal=DB_RO_PASSWORD='XXXX' --from-literal=ALCYON_SERVICE_PASSWORD='XXXX' --from-literal=ALCYON_PORTAL_PASSWORD='XXXX' --from-literal=KAFKA_PASSWORD='XXXX' -n alcyon-app

# S3 secret for FieldService
kubectl create secret generic s3-secret --from-literal=accesskey='XXXX' --from-literal=secretkey='XXXX' -n alcyon-app
# archive secret

helm template . -n alcyon-release  -f ../values-uat-au-qld-global.yaml -f values-uat-au-qld.yaml --namespace alcyon-app > test.yaml

helm install --debug --dry-run alcyon-release -n alcyon-app  -f ../values-uat-au-qld-global.yaml -f values-uat-au-qld.yaml .

# To install
helm install alcyon-release -n alcyon-app  -f ../values-uat-au-qld-global.yaml -f values-uat-au-qld.yaml .

# To upgrade the chart
helm diff upgrade alcyon-release -n alcyon-app  -f ../values-uat-au-qld-global.yaml -f values-uat-au-qld.yaml .
# make sure only your changes are there then run
helm upgrade alcyon-release -n alcyon-app  -f ../values-uat-au-qld-global.yaml -f values-uat-au-qld.yaml .

helm uninstall -n alcyon-app alcyon-release
````

### au-qld Chart

````
cd au-qld-chart

# au-qld-secret for au-qld chart(s)
kubectl create secret generic au-qld-secret --from-literal=TMR_INTERFACR_PASSWORD='XXXX' -n au-qld

helm template . -n au-qld-release  -f ../values-uat-au-qld-global.yaml -f values-uat-au-qld.yaml --namespace alcyon-app > test.yaml

helm install --debug --dry-run au-qld-release -n au-qld  -f ../values-uat-au-qld-global.yaml -f values-uat-au-qld.yaml .

# To install
helm install au-qld-release -n au-qld  -f ../values-uat-au-qld-global.yaml -f values-uat-au-qld.yaml .

# To upgrade the chart
helm diff upgrade au-qld-release -n au-qld  -f ../values-uat-au-qld-global.yaml -f values-uat-au-qld.yaml .
# make sure only your changes are there then run
helm upgrade au-qld-release -n au-qld  -f ../values-uat-au-qld-global.yaml -f values-uat-au-qld.yaml .

helm uninstall -n au-qld au-qld-release
````

## Utility Chart

Prerequisite: Create a Postgres Schema for Rundeck application.
> Refer to [Utility Readme file](utility-chart/README.md) for DB instructions.


````
cd utility-chart

kubectl create secret docker-registry regsecret --docker-server=dockerp.rtsprod.net --docker-username=redflex --docker-password=redflex --docker-email=cst@redflex.com -n utility
kubectl create secret generic utility-secret --from-literal=RUNDECK_DATABASE_PASSWORD='XXXX' --from-literal=RUNDECK_ALCYON_DB_PASSWORD='XXXX' --from-literal=RUNDECK_ALCYON_ADMIN_PASSWORD='XXXX' --from-literal=BIX_DB_PASSWORD='XXXX' --from-literal=TRAFFIC_STATS_DB_PASSWORD='XXXX' --from-literal=NOTIFYR_MAIL_PASSWORD='XXXX' --from-literal=RUNDECK_ALERTS_MAIL_SMTP_PASSWORD='XXXX' -n utility

helm repo add incubator http://storage.googleapis.com/kubernetes-charts-incubator  
helm dependency update

helm template  -f ../values-uat-au-qld-global.yaml -f values-uat-au-qld.yaml . -n utility-release --namespace utility > test.yaml

helm install --debug --dry-run utility-release --namespace utility  -f ../values-uat-au-qld-global.yaml -f values-uat-au-qld.yaml .

# To install
helm install utility-release --namespace utility  -f ../values-uat-au-qld-global.yaml -f values-uat-au-qld.yaml .

# To purge the release
helm uninstall -n utility utility-release

# To run upgrade.
helm diff upgrade utility-release --namespace utility  -f ../values-uat-au-qld-global.yaml -f values-uat-au-qld.yaml .
# make sure only your changes are there then run
helm upgrade utility-release --namespace utility  -f ../values-uat-au-qld-global.yaml -f values-uat-au-qld.yaml .

````


## Migration Chart

````
cd migration-chart

kubectl create secret generic mongo-secret --from-literal=MONGO_PASSWORD='XXXX' -n migration
kubectl create secret generic migration-secret --from-literal=ORACLE_PASSWORD='XXXX' --from-literal=ALCYON_SERVICE_PASSWORD='XXXX' --from-literal=SIDEKIQ_USERNAME='XXXX' --from-literal=SIDEKIQ_PASSWORD='XXXX' -n migration

helm template -f ../values-uat-au-qld-global.yaml  -f values-uat-au-qld.yaml . -n migration-release --namespace migration > test.yaml

helm install --debug --dry-run -n migration-release --namespace migration -f ../values-uat-au-qld-global.yaml  -f values-uat-au-qld.yaml .

# To install
helm install migration-release --namespace migration -f ../values-uat-au-qld-global.yaml  -f values-uat-au-qld.yaml .

# To purge the release
helm uninstall -n migration migration-release

# To run upgrade.
helm diff upgrade migration-release --namespace migration -f ../values-uat-au-qld-global.yaml  -f values-uat-au-qld.yaml .
# make sure only your changes are there then run
helm upgrade migration-release --namespace migration -f ../values-uat-au-qld-global.yaml  -f values-uat-au-qld.yaml .
````

## ARM Chart

````
cd arm-chart

kubectl create secret docker-registry regsecret --docker-server=docker.rtsprod.net  --docker-username=redflex --docker-password=XXX --docker-email=cst@redflex.com -n arm
kubectl create secret generic arm-secret --from-literal=REGISTRR_PASSWORD='XXXX' -n arm

helm template  -f ../values-uat-au-qld-global.yaml -f values-uat-au-qld.yaml . -n arm-release --namespace arm > test.yaml

helm install --debug --dry-run -n arm-release --namespace arm  -f ../values-uat-au-qld-global.yaml -f values-uat-au-qld.yaml .

# To install
helm install arm-release --namespace arm  -f ../values-uat-au-qld-global.yaml -f values-uat-au-qld.yaml .

# To purge the release
helm uninstall -n arm arm-release

# To run upgrade.
helm diff upgrade arm-release --namespace arm  -f ../values-uat-au-qld-global.yaml -f values-uat-au-qld.yaml .
# make sure only your changes are there then run
helm upgrade arm-release --namespace arm  -f ../values-uat-au-qld-global.yaml -f values-uat-au-qld.yaml .

````

## Stub Chart

````
cd /data/stub-chart

kubectl create secret docker-registry regsecret --docker-server=docker.rtsprod.net  --docker-username=redflex --docker-password=XXX --docker-email=cst@redflex.com -n stub

helm template  -f ../values-uat-au-qld-global.yaml -f values-uat-au-qld.yaml . -n stub-release --namespace stub > test.yaml

helm install --debug --dry-run -n stub-release --namespace stub  -f ../values-uat-au-qld-global.yaml -f values-uat-au-qld.yaml .

# To install
helm install stub-release --namespace stub  -f ../values-uat-au-qld-global.yaml -f values-uat-au-qld.yaml .

# To purge the release
helm uninstall -n stub stub-release

# To run upgrade.
helm diff upgrade stub-release --namespace stub  -f ../values-uat-au-qld-global.yaml -f values-uat-au-qld.yaml .
# make sure only your changes are there then run
helm upgrade stub-release --namespace stub  -f ../values-uat-au-qld-global.yaml -f values-uat-au-qld.yaml .

````
