# Helm chart installation instruction for US PreProd

## Installation


1. Run the kubernetes-tools container via docker-compose on cluster admin instance.

2. Tiller is NOT required in Helm 3.
    
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
    
    kubectl create ns migration  
    kubectl label namespace/migration name=migration  
    
    kubectl create ns arm  
    kubectl label namespace/arm name=arm  
    
    kubectl label namespace/default name=default 
    kubectl label namespace/kube-system name=kube-system 
    
    kubectl create ns stub  
    kubectl label namespace/stub name=stub  
    
    kubectl create ns alcyon-control
    kubectl label namespace/alcyon-control name=alcyon-control
    ````
     
4. Setup the image pull secret in all namespaces
````
kubectl create secret docker-registry regsecret --docker-server=docker.rtsprod.net --docker-username=<username> --docker-password=<password> --docker-email=cst@redflex.com.au -n <namespace>
    
#eg., 
kubectl delete secret regsecret -n alcyon-control
kubectl delete secret regsecret -n arm
kubectl delete secret regsecret -n migration
kubectl delete secret regsecret -n stub
kubectl delete secret regsecret -n utility
kubectl create secret docker-registry regsecret --docker-server=dockerp.rtsprod.net --docker-username=redflex --docker-password=redflex --docker-email=cst@redflex.com.au -n alcyon-app
kubectl create secret docker-registry regsecret --docker-server=dockerp.rtsprod.net --docker-username=redflex --docker-password=redflex --docker-email=cst@redflex.com.au -n alcyon-control
kubectl create secret docker-registry regsecret --docker-server=dockerp.rtsprod.net --docker-username=redflex --docker-password=redflex --docker-email=cst@redflex.com.au -n arm
kubectl create secret docker-registry regsecret --docker-server=dockerp.rtsprod.net --docker-username=redflex --docker-password=redflex --docker-email=cst@redflex.com.au -n migration
kubectl create secret docker-registry regsecret --docker-server=dockerp.rtsprod.net --docker-username=redflex --docker-password=redflex --docker-email=cst@redflex.com.au -n stub 
kubectl create secret docker-registry regsecret --docker-server=dockerp.rtsprod.net --docker-username=redflex --docker-password=redflex --docker-email=cst@redflex.com.au -n utility
```` 

## Deploy

### Base chart

````
 
# To purge the release
helm uninstall -n base base-release 

# If base-release name was used earlier, uninstall with the following command
helm uninstall -n base base-release 

helm dependency update

helm template base-release -n base -f ../values-us-stg-global.yaml  -f values-us-stg.yaml . > test.yaml

# To install
helm install base-release  --namespace base -f ../values-us-stg-global.yaml  -f values-us-stg.yaml .

# To upgrade the chart
helm diff upgrade base-release --namespace base -f ../values-us-stg-global.yaml  -f values-us-stg.yaml .
# make sure only your changes are there then run
helm upgrade base-release --namespace base -f ../values-us-stg-global.yaml  -f values-us-stg.yaml .

# To verify status
helm status base-release
````

### Monitoring chart

````
kubectl create secret generic monitoring-secret --from-literal=GRAFANA_USER='XXX' --from-literal=GRAFANA_PASSWORD='XXXX' --from-literal=ES_PASSWORD='XXXX' -n monitoring
kubectl create secret generic monitoring-secret --from-literal=GRAFANA_USER='admin' --from-literal=GRAFANA_PASSWORD='Gr#f#n#S#cr#t' --from-literal=ES_PASSWORD='Install123$' -n monitoring

helm repo add kiwigrid https://kiwigrid.github.io
helm repo add grafana https://grafana.github.io/helm-charts  
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts  
helm dependency update

# Run this prior to install, required for nri-bundle (new-relic)
kubectl apply -f https://raw.githubusercontent.com/pixie-labs/pixie/main/k8s/operator/crd/base/px.dev_viziers.yaml
kubectl apply -f https://raw.githubusercontent.com/pixie-labs/pixie/main/k8s/operator/helm/crds/olm_crd.yaml

# To purge the release
helm uninstall -n monitoring monitoring-release 

helm template monitoring-release -f ../values-us-stg-global.yaml  -f values-us-stg.yaml -n monitoring . > test.yaml

# To install
helm install monitoring-release -n monitoring -f ../values-us-stg-global.yaml  -f values-us-stg.yaml .

# To upgrade the chart when new subchart is added.
helm diff upgrade monitoring-release -n monitoring  -f ../values-us-stg-global.yaml  -f values-us-stg.yaml .
# make sure only your changes are there then run
helm upgrade monitoring-release -n monitoring  -f ../values-us-stg-global.yaml  -f values-us-stg.yaml .

# To verify status
helm status monitoring-release

helm uninstall -n <namespace> monitoring-release 
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

kubectl create secret generic alcyon-secret --from-literal=DB_PASSWORD='XXXX' --from-literal=DB_RO_PASSWORD='XXXX' --from-literal=ALCYON_SERVICE_PASSWORD='XXXX' --from-literal=ALCYON_PORTAL_PASSWORD='XXXX' -n alcyon-app

# S3 secret for FieldService
kubectl create secret generic s3-secret --from-literal=accesskey='XXXX' --from-literal=secretkey='XXXX' -n alcyon-app

helm template . -n alcyon-release -f ../values-us-stg-global.yaml  -f values-us-stg.yaml --namespace alcyon-app > test.yaml

helm install --debug --dry-run alcyon-release -n alcyon-app -f ../values-us-stg-global.yaml  -f values-us-stg.yaml .

# To install
helm install alcyon-release -n alcyon-app -f ../values-us-stg-global.yaml  -f values-us-stg.yaml .

# To upgrade the chart
helm diff upgrade alcyon-release -n alcyon-app -f ../values-us-stg-global.yaml  -f values-us-stg.yaml .
# make sure only your changes are there then run
helm upgrade alcyon-release -n alcyon-app -f ../values-us-stg-global.yaml  -f values-us-stg.yaml .

helm uninstall -n alcyon-app alcyon-release
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

kubectl create secret generic usa-secret --from-literal=SEEKR_PASSWORD='XXXX' --from-literal=SACCA_COURT_EXPORT_PASSWORD='XXXX' --from-literal=SEEKR_WADOL_PASSWORD='XXXX'  --from-literal=WIZARD_PASSWORD='XXXX'  --from-literal=SEEKR_NYPREEDLOOKUP_ACCOUNTCREDENTIALS_PAWZSE_PASSWORD='XXXX' --from-literal=COLLECTR_DB_PASSWORD='XXXX' -n prod-alcyon

kubectl create secret generic recaptcha-secret --from-literal=sitekey='XXX' --from-literal=secretkey='XXXX'  -n alcyon-app

kubectl create secret generic wip-queue-stats-secret --from-literal=WIP_QUEUE_STATS_PASSWORD='XXXX' -n alcyon-app

helm template -f ../values-us-stg-global.yaml  -f values-us-stg.yaml . -n usa-release --namespace alcyon-app > test.yaml

helm install --debug --dry-run -n usa-release --namespace alcyon-app -f ../values-us-stg-global.yaml  -f values-us-stg.yaml .

# To install
helm install usa-release --namespace alcyon-app -f ../values-us-stg-global.yaml  -f values-us-stg.yaml .

# To purge the release
helm uninstall -n alcyon-app usa-release

# To upgrade.
helm diff upgrade usa-release --namespace alcyon-app -f ../values-us-stg-global.yaml  -f values-us-stg.yaml .
# make sure only your changes are there then run
helm upgrade usa-release --namespace alcyon-app -f ../values-us-stg-global.yaml  -f values-us-stg.yaml .
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

helm template -f ../values-us-stg-global.yaml  -f values-us-stg.yaml . -n utility-release --namespace utility > test.yaml

helm install --debug --dry-run utility-release --namespace utility -f ../values-us-stg-global.yaml  -f values-us-stg.yaml .

# To install
helm install utility-release --namespace utility -f ../values-us-stg-global.yaml  -f values-us-stg.yaml .

# To upgrade
helm diff upgrade utility-release --namespace utility -f ../values-us-stg-global.yaml  -f values-us-stg.yaml .
# make sure only your changes are there then run
helm  upgrade utility-release --namespace utility -f ../values-us-stg-global.yaml  -f values-us-stg.yaml .

# To purge the release
helm uninstall -n utility utility-release

# To run upgrade.
helm upgrade utility-release --namespace utility -f ../values-us-stg-global.yaml  -f values-us-stg.yaml .

````

## Migration Chart

````
cd migration-chart
  
helm dependency update

helm template -f ../values-us-stg-global.yaml  -f values-us-stg-sacca.yaml . -n migration-release --namespace migration > test.yaml

helm install --debug --dry-run -n migration-release --namespace migration -f ../values-us-stg-global.yaml  -f values-us-stg-sacca.yaml .

# To install
helm install migration-release --namespace migration -f ../values-us-stg-global.yaml  -f values-us-stg-sacca.yaml .

# To upgrade
helm diff upgrade migration-release --namespace migration -f ../values-us-stg-global.yaml  -f values-us-stg-sacca.yaml .
# make sure only your changes are there then run
helm  upgrade migration-release --namespace migration -f ../values-us-stg-global.yaml  -f values-us-stg-sacca.yaml .

# To purge the release
helm uninstall -n migration migration-release

# To run upgrade.
helm upgrade migration-release --namespace migration -f ../values-us-stg-global.yaml  -f values-us-stg-sacca.yaml .

````

## ARM Chart

````
cd arm-chart

kubectl create secret docker-registry regsecret --docker-server=docker.rtsprod.net  --docker-username=redflex --docker-password=XXX --docker-email=cst@redflex.com -n arm
kubectl create secret generic arm -secret --from-literal=DATASOURCE_PASSWORD='XXXX' -n arm

helm template  -f ../values-us-stg-global.yaml -f values-us-stg.yaml . -n arm-release --namespace arm > test.yaml

helm install --debug --dry-run -n arm-release --namespace arm  -f ../values-us-stg-global.yaml -f values-us-stg.yaml .

# To install
helm install arm-release --namespace arm  -f ../values-us-stg-global.yaml -f values-us-stg.yaml .

# To purge the release
helm uninstall -n arm arm-release

# To run upgrade.
helm diff upgrade arm-release --namespace arm  -f ../values-us-stg-global.yaml -f values-us-stg.yaml .
# make sure only your changes are there then run
helm upgrade arm-release --namespace arm  -f ../values-us-stg-global.yaml -f values-us-stg.yaml .

````

## Stub Chart

````
cd stub-chart

kubectl create secret docker-registry regsecret --docker-server=docker.rtsprod.net  --docker-username=redflex --docker-password=XXX --docker-email=cst@redflex.com -n stub

helm template  -f ../values-us-stg-global.yaml -f values-us-stg.yaml . -n stub-release --namespace stub > test.yaml

helm install --debug --dry-run -n stub-release --namespace stub  -f ../values-us-stg-global.yaml -f values-us-stg.yaml .

# To install
helm install stub-release --namespace stub  -f ../values-us-stg-global.yaml -f values-us-stg.yaml .

# To purge the release
helm uninstall -n stub stub-release

# To run upgrade.
helm diff upgrade stub-release --namespace stub  -f ../values-us-stg-global.yaml -f values-us-stg.yaml .
# make sure only your changes are there then run
helm upgrade stub-release --namespace stub  -f ../values-us-stg-global.yaml -f values-us-stg.yaml .

````

## Alcyon Control Chart

````
cd alcyon-control-chart
helm dependency update

kubectl create secret docker-registry regsecret --docker-server=docker.rtsprod.net --docker-username=XXXX --docker-password=redflex --docker-email=cst@redflex.com  -n alcyon-control

kubectl create secret generic alcyon-control-secret --from-literal=GOVERNR_DB_PASSWORD='XXXX' -n alcyon-control

helm template -f ../values-us-stg-global.yaml  -f values-us-stg.yaml . -n alcyon-control-release --namespace alcyon-control > test.yaml

helm install --debug --dry-run -n alcyon-control-release --namespace alcyon-control  -f ../values-us-stg-global.yaml  -f values-us-stg.yaml .

# To install
helm install alcyon-control-release --namespace alcyon-control  -f ../values-us-stg-global.yaml  -f values-us-stg.yaml .

# To purge the release
helm uninstall -n alcyon-control alcyon-control-release

# To upgrade.
helm diff upgrade alcyon-control-release --namespace alcyon-control  -f ../values-us-stg-global.yaml  -f values-us-stg.yaml .
# make sure only your changes are there then run
helm upgrade alcyon-control-release --namespace alcyon-control  -f ../values-us-stg-global.yaml  -f values-us-stg.yaml .
````
