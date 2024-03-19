# Helm chart installation instruction for US PreProd

## Installation

Login to cluster admin instance in GovCloud. Run the following command to get the kubectl config
````
scp ec2-user@10.202.1.97:/home/ec2-user/.kube/config ~/kube/config
````

1. Run the kubernetes-tools container
    ````
    docker run -it --rm -v /home/alcyon/.kube:/root/.kube -v /home/alcyon/redflex-helm-charts:/data docker.rtsprod.net/common/kubernetes-tools:latest
    ````

2. Setup Tiller service account with correct access for HELM and install tiller
    ````
    kubectl create -f helm-rbac-config.yaml
    helm init --service-account tiller --upgrade
    ````
    
3. Setup namespaces

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
    
    kubectl create ns on-prem  
    kubectl label namespace/on-prem  name=on-prem  
    
    kubectl create ns arm  
    kubectl label namespace/arm name=arm  
    
    kubectl label namespace/default name=default 
    kubectl label namespace/kube-system name=kube-system 
    ````
     
4. Setup the image pull secret in all namespaces
    ````
    kubectl create secret docker-registry regsecret --docker-server=dockerp.rtsprod.net --docker-username=<username> --docker-password=<password> --docker-email=cst@redflex.com.au -n <namespace>
    
    #eg., 
    kubectl create secret docker-registry regsecret --docker-server=dockerp.rtsprod.net --docker-username=redflex --docker-password=XXXX --docker-email=cst@redflex.com.au -n alcyon-app 
    ```` 

## Deploy

### Base chart

````

# To purge the release
helm uninstall -n base base-release 

# If system-release name was used earlier, uninstall with the following command
helm uninstall -n base system-release 

helm dependency update

helm template . -n base-release  -f ../values-us-govcloud-global.yaml -f values-us-govcloud.yaml > test.yaml

# To install
helm install base-release  -n base  -f ../values-us-govcloud-global.yaml -f values-us-govcloud.yaml .


# To upgrade the chart
helm diff upgrade base-release -n base  -f ../values-us-govcloud-global.yaml -f values-us-govcloud.yaml .
# make sure only your changes are there then run
helm upgrade base-release -n base  -f ../values-us-govcloud-global.yaml -f values-us-govcloud.yaml .

# To verify status
helm status base-release
````

### Monitoring chart

````
kubectl create secret generic monitoring-secret --from-literal=GRAFANA_USER='XXX' --from-literal=GRAFANA_PASSWORD='XXXX' -n monitoring

helm repo add kiwigrid https://kiwigrid.github.io
helm repo add grafana https://grafana.github.io/helm-charts  
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts  
  
helm dependency update

# To purge the release
helm uninstall -n monitoring monitoring-release 

helm dependency update

helm template . -n monitoring-release  -f ../values-us-govcloud-global.yaml -f values-us-govcloud.yaml > test.yaml

# To install
helm install monitoring-release -n monitoring   -f ../values-us-govcloud-global.yaml -f values-us-govcloud.yaml .

# To upgrade the chart when new subchart is added.
helm diff upgrade monitoring-release -n monitoring   -f ../values-us-govcloud-global.yaml -f values-us-govcloud.yaml .
# make sure only your changes are there then run
helm upgrade monitoring-release -n monitoring   -f ../values-us-govcloud-global.yaml -f values-us-govcloud.yaml .

# To verify status
helm status monitoring-release

helm uninstall monitoring-release 
````

Once helm chart is deployed, follow the steps in monitoring-chart/README.md file.

TODO: remove on-prem chart after ActiveMQ dependency is fixed

### On Prem chart

````
# To purge the release
helm uninstall -n on-prem on-prem-release 

helm template on-prem-release -f ../values-us-govcloud-global.yaml  -f values-us-govcloud.yaml -n on-prem . > test.yaml

# To install
helm install on-prem-release -n on-prem -f ../values-us-govcloud-global.yaml  -f values-us-govcloud.yaml .

# To upgrade the chart when new subchart is added.
helm diff upgrade on-prem-release -n on-prem  -f ../values-us-govcloud-global.yaml  -f values-us-govcloud.yaml .
# make sure only your changes are there then run
helm upgrade on-prem-release -n on-prem  -f ../values-us-govcloud-global.yaml  -f values-us-govcloud.yaml .

# To verify status
helm status on-prem-release

helm uninstall -n <namespace> on-prem-release 
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
cd alcyon-chart
kubectl create secret generic alcyon-secret --from-literal=DB_PASSWORD='XXXX' --from-literal=DB_RO_PASSWORD='XXXX' --from-literal=ALCYON_SERVICE_PASSWORD='XXXX' --from-literal=ALCYON_PORTAL_PASSWORD='XXXX' -n alcyon-app

kubectl create secret generic s3-secret --from-literal=accesskey='XXXX' --from-literal=secretkey='XXXX' -n alcyon-app

helm template . -n alcyon-release  -f ../values-us-govcloud-global.yaml -f values-us-govcloud.yaml -n alcyon-app > test.yaml

helm install --debug --dry-run -n alcyon-release -n alcyon-app  -f ../values-us-govcloud-global.yaml -f values-us-govcloud.yaml .

# To install
helm install alcyon-release -n alcyon-app  -f ../values-us-govcloud-global.yaml -f values-us-govcloud.yaml .

# To upgrade the chart
helm diff upgrade alcyon-release -n alcyon-app  -f ../values-us-govcloud-global.yaml -f values-us-govcloud.yaml .
# make sure only your changes are there then run
helm upgrade alcyon-release -n alcyon-app  -f ../values-us-govcloud-global.yaml -f values-us-govcloud.yaml .

helm uninstall alcyon-release -n alcyon-app
````

### USA Chart

You need to manually create usa-secret with the following keys
- LEDGR_PASSWORD
- SEEKR_PASSWORD
- SEEKR_WADOL_PASSWORD

You need to manually create recaptcha-secret with the following keys
- sitekey
- secretkey


````
cd usa-chart

kubectl create secret generic usa-secret --from-literal=SEEKR_PASSWORD='AL#Y0N_SEEKR_SE#RET' --from-literal=SEEKR_WADOL_PASSWORD='XXXX' --from-literal=LEDGR_PASSWORD='AL#Y0N_LEDGR_SE#RET'  -n alcyon-app
kubectl create secret generic recaptcha-secret --from-literal=sitekey='XXX' --from-literal=secretkey='XXXX'  -n alcyon-app
kubectl create secret generic wip-queue-stats-secret --from-literal=WIP_QUEUE_STATS_PASSWORD='XXXX' -n alcyon-app

helm dependency update

#TODO: Remove when functionality is released to production
rm -r wizard/
rm -r wizardportal/
rm -r alcyongreen/

helm template  -f ../values-us-govcloud-global.yaml -f values-us-govcloud.yaml . -n usa-release -n alcyon-app > test.yaml

helm install --debug --dry-run -n usa-release -n alcyon-app  -f ../values-us-govcloud-global.yaml -f values-us-govcloud.yaml .

# To install
helm install usa-release -n alcyon-app  -f ../values-us-govcloud-global.yaml -f values-us-govcloud.yaml .

# To purge the release
helm uninstall usa-release -n alcyon-app

# To upgrade.
helm diff upgrade usa-release -n alcyon-app  -f ../values-us-govcloud-global.yaml -f values-us-govcloud.yaml .
# make sure only your changes are there then run
helm upgrade usa-release -n alcyon-app  -f ../values-us-govcloud-global.yaml -f values-us-govcloud.yaml .
````

## Utility Chart

Prerequisite: Create a Postgres Schema for Rundeck application.
> Refer to [Utility Readme file](utility-chart/README.md) for DB instructions.


````
cd utility-chart

kubectl create secret docker-registry regsecret --docker-server=dockerp.rtsprod.net --docker-username=redflex --docker-password=redflex --docker-email=cst@redflex.com -n utility
kubectl create secret generic utility-secret --from-literal=RUNDECK_DATABASE_PASSWORD='XXXX' --from-literal=RUNDECK_ALCYON_DB_PASSWORD='XXXX' --from-literal=RUNDECK_ALCYON_ADMIN_PASSWORD='XXXX' --from-literal=BIX_DB_PASSWORD='XXXX' --from-literal=TRAFFIC_STATS_DB_PASSWORD='XXXX' -n utility

helm dependency update

helm template -f ../values-us-govcloud-global.yaml  -f values-us-govcloud.yaml . -n utility-release --namespace utility > test.yaml

helm install --debug --dry-run -n utility-release --namespace utility -f ../values-us-govcloud-global.yaml  -f values-us-govcloud.yaml .

# To install
helm install utility-release --namespace utility -f ../values-us-govcloud-global.yaml  -f values-us-govcloud.yaml .

# To upgrade
helm diff upgrade utility-release --namespace utility -f ../values-us-govcloud-global.yaml  -f values-us-govcloud.yaml .
# make sure only your changes are there then run
helm  upgrade utility-release --namespace utility -f ../values-us-govcloud-global.yaml  -f values-us-govcloud.yaml .

# To purge the release
helm uninstall -n utility utility-release
````

## Migration Chart

````
cd migration-chart
  
helm dependency update

helm template -f ../values-us-govcloud-global.yaml  -f values-us-govcloud-sacca.yaml . -n migration-release --namespace migration > test.yaml

helm install --debug --dry-run -n migration-release --namespace migration -f ../values-us-govcloud-global.yaml  -f values-us-govcloud-sacca.yaml .

# To install
helm install migration-release --namespace migration -f ../values-us-govcloud-global.yaml  -f values-us-govcloud-sacca.yaml .

# To upgrade
helm diff upgrade migration-release --namespace migration -f ../values-us-govcloud-global.yaml  -f values-us-govcloud-lametro.yaml .
# make sure only your changes are there then run
helm  upgrade migration-release --namespace migration -f ../values-us-govcloud-global.yaml  -f values-us-govcloud-lametro.yaml .

# To purge the release
helm uninstall -n migration migration-release

# To run upgrade.
helm upgrade migration-release --namespace migration -f ../values-us-govcloud-global.yaml  -f values-us-govcloud-sacca.yaml .

````

## ARM Chart

````
cd arm-chart

kubectl create secret docker-registry regsecret --docker-server=dockerp.rtsprod.net  --docker-username=redflex --docker-password=XXX --docker-email=cst@redflex.com -n arm
kubectl create secret generic arm -secret --from-literal=DATASOURCE_PASSWORD='XXXX' -n arm

helm template  -f ../values-us-govcloud-global.yaml -f values-us-govcloud.yaml . -n arm-release --namespace arm > test.yaml

helm install --debug --dry-run -n arm-release --namespace arm  -f ../values-us-govcloud-global.yaml -f values-us-govcloud.yaml .

# To install
helm install arm-release --namespace arm  -f ../values-us-govcloud-global.yaml -f values-us-govcloud.yaml .
#installation during migration 
helm install arm-release --namespace arm  -f ../values-us-govcloud-global.yaml -f values-us-govcloud-migration.yaml .

# To purge the release
helm uninstall -n arm arm-release

# To run upgrade.
helm diff upgrade arm-release --namespace arm  -f ../values-us-govcloud-global.yaml -f values-us-govcloud.yaml .
# make sure only your changes are there then run
helm upgrade arm-release --namespace arm  -f ../values-us-govcloud-global.yaml -f values-us-govcloud.yaml .

````