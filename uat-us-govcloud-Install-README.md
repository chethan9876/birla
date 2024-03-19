# Helm chart installation instruction for US-GOVCLOUD EKS cluster

## Cluster login setup

1. Run the kubernetes-tools container on the admin box.
`docker run -it --rm -v /usr/share/redflex/redflex-helm-charts/:/data/ dockerp.rtsprod.net/common/aws-kubernetes-tools:latest`

2. Setup Kubectl context 
`aws eks --region us-gov-west-1 update-kubeconfig --name uat-us-govcloud-eks --profile govcloud`
   
   
## Instalation

1. Label the nodes (do for all nodes)
````
kubectl get node 
kubectl label node ip-xxxx.ap-southeast-2.compute.internal node-role.kubernetes.io/worker=worker 
```` 

2. Setup namespaces

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
    
    kubectl create ns alcyon-fs 
    kubectl label namespace/alcyon-fs name=alcyon-fs 
    
    kubectl label namespace/default name=default 
    kubectl label namespace/kube-system name=kube-system  
   
    kubectl create ns alcyon-control
    kubectl label namespace/alcyon-control name=alcyon-control
    
    kubectl create ns us
    kubectl label namespace/us name=us
    
    ````
     
3. Setup the image pull secret in all namespaces
    ````
    kubectl create secret docker-registry regsecret --docker-server=dockerp.rtsprod.net --docker-username=<username> --docker-password=<password> --docker-email=cst@redflex.com.au -n <namespace>
    
    #eg., 
    kubectl create secret docker-registry regsecret --docker-server=dockerp.rtsprod.net --docker-username=redflex --docker-password=XXX --docker-email=cst@redflex.com -n alcyon-app
    kubectl create secret docker-registry regsecret --docker-server=dockerp.rtsprod.net --docker-username=redflex --docker-password=XXX --docker-email=cst@redflex.com -n alcyon-control
    kubectl create secret docker-registry regsecret --docker-server=dockerp.rtsprod.net --docker-username=redflex --docker-password=XXX --docker-email=cst@redflex.com -n alcyon-fs
    kubectl create secret docker-registry regsecret --docker-server=dockerp.rtsprod.net --docker-username=redflex --docker-password=XXX --docker-email=cst@redflex.com -n us
    kubectl create secret docker-registry regsecret --docker-server=dockerp.rtsprod.net --docker-username=redflex --docker-password=XXX --docker-email=cst@redflex.com -n arm
    kubectl create secret docker-registry regsecret --docker-server=dockerp.rtsprod.net --docker-username=redflex --docker-password=XXX --docker-email=cst@redflex.com -n migration
    kubectl create secret docker-registry regsecret --docker-server=dockerp.rtsprod.net --docker-username=redflex --docker-password=XXX --docker-email=cst@redflex.com -n utility
   
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

# not required:
helm template eks-release -n kube-system -f ../values-uat-us-govcloud-global.yaml -f values-uat-us-govcloud.yaml . > test.yaml

# To install

cd .\eks-chart\
helm install eks-release  --namespace kube-system  -f ../values-uat-us-govcloud-global.yaml -f values-uat-us-govcloud.yaml .


# To upgrade the chart
helm diff upgrade eks-release --namespace kube-system -f ../values-uat-us-govcloud-global.yaml -f values-uat-us-govcloud.yaml .
# make sure only your changes are there then run
helm upgrade eks-release --namespace kube-system  -f ../values-uat-us-govcloud-global.yaml -f values-uat-us-govcloud.yaml .

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

helm template base-release -n base -f ../values-uat-us-govcloud-global.yaml -f values-uat-us-govcloud.yaml . > test.yaml

# To install
helm install base-release  --namespace base  -f ../values-uat-us-govcloud-global.yaml -f values-uat-us-govcloud.yaml .

# To upgrade the chart.
helm diff upgrade base-release --namespace base -f ../values-uat-us-govcloud-global.yaml -f values-uat-us-govcloud.yaml .
# make sure only your changes are there then run
helm upgrade base-release --namespace base -f ../values-uat-us-govcloud-global.yaml -f values-uat-us-govcloud.yaml .

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
helm repo add nri-bundle helm-charts.newrelic.com

# Run this prior to install, required for nri-bundle (new-relic)
kubectl apply -f https://raw.githubusercontent.com/pixie-labs/pixie/main/k8s/operator/crd/base/px.dev_viziers.yaml
kubectl apply -f https://raw.githubusercontent.com/pixie-labs/pixie/main/k8s/operator/helm/crds/olm_crd.yaml
  
helm dependency update

# To purge the release
helm uninstall -n monitoring monitoring-release 

helm template monitoring-release  -f ../values-uat-us-govcloud-global.yaml -f values-uat-us-govcloud.yaml -n monitoring . > test.yaml

# To install
helm install monitoring-release -n monitoring  -f ../values-uat-us-govcloud-global.yaml -f values-uat-us-govcloud.yaml .

# To upgrade the chart when new subchart is added.
helm diff upgrade monitoring-release -n monitoring   -f ../values-uat-us-govcloud-global.yaml -f values-uat-us-govcloud.yaml .
# make sure only your changes are there then run
helm upgrade monitoring-release -n monitoring   -f ../values-uat-us-govcloud-global.yaml -f values-uat-us-govcloud.yaml .

# To verify status
helm status monitoring-release

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

kubectl create secret generic alcyon-secret --from-literal=DB_PASSWORD='XXXX' --from-literal=DB_RO_PASSWORD='XXXX' --from-literal=ALCYON_SERVICE_PASSWORD='XXXX' --from-literal=ALCYON_PORTAL_PASSWORD='XXXX' -n alcyon-app

# S3 secret for FieldService
kubectl create secret generic s3-secret --from-literal=accesskey='XXXX' --from-literal=secretkey='XXXX' -n alcyon-app
# archive secret
kubectl create secret generic archive-secret --from-literal=accesskey='XXXX' --from-literal=secretkey='XXXX' -n alcyon-app

helm template . -n alcyon-release  -f ../values-uat-us-govcloud-global.yaml -f values-uat-us-govcloud.yaml --namespace alcyon-app > test.yaml

helm install --debug --dry-run alcyon-release -n alcyon-app  -f ../values-uat-us-govcloud-global.yaml -f values-uat-us-govcloud.yaml .

# To install
helm install alcyon-release -n alcyon-app  -f ../values-uat-us-govcloud-global.yaml -f values-uat-us-govcloud.yaml .

# To upgrade the chart
helm diff upgrade alcyon-release -n alcyon-app  -f ../values-uat-us-govcloud-global.yaml -f values-uat-us-govcloud.yaml .
# make sure only your changes are there then run
helm upgrade alcyon-release -n alcyon-app  -f ../values-uat-us-govcloud-global.yaml -f values-uat-us-govcloud.yaml .

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

helm dependency update

kubectl create secret generic alcyon-secret --from-literal=ALCYON_SERVICE_PASSWORD='XXXX' --from-literal=ALCYON_PORTAL_PASSWORD='XXXX' -n us
kubectl create secret generic usa-secret --from-literal=SEEKR_VAULT_ROLE_ID='XXXX' --from-literal=SEEKR_VAULT_SECRET_ID='XXXX' --from-literal=SEEKR_WADOL_PASSWORD='XXXX  --from-literal=WIZARD_PASSWORD='XXXX' --from-literal=COLLECTR_DB_PASSWORD='XXXX' --from-literal=WIZARD_REPORTS_DB_PASSWORD='XXXX' -n us
kubectl create secret generic recaptcha-secret --from-literal=sitekey='XXX' --from-literal=secretkey='XXXX'  -n us
kubectl create secret generic wip-queue-stats-secret --from-literal=WIP_QUEUE_STATS_PASSWORD='XXXX' -n us

helm template  -f ../values-uat-us-govcloud-global.yaml -f values-uat-us-govcloud.yaml . -n usa-release --namespace us > test.yaml

helm install --debug --dry-run -n usa-release --namespace us  -f ../values-uat-us-govcloud-global.yaml -f values-uat-us-govcloud.yaml .

# To install
helm install usa-release --namespace us  -f ../values-uat-us-govcloud-global.yaml -f values-uat-us-govcloud.yaml .

# To purge the release
helm uninstall -n us usa-release

# To upgrade.
helm diff upgrade usa-release --namespace us  -f ../values-uat-us-govcloud-global.yaml -f values-uat-us-govcloud.yaml .
# make sure only your changes are there then run
helm upgrade usa-release --namespace us  -f ../values-uat-us-govcloud-global.yaml -f values-uat-us-govcloud.yaml .
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

helm template  -f ../values-uat-us-govcloud-global.yaml -f values-uat-us-govcloud.yaml . -n utility-release --namespace utility > test.yaml

helm install --debug --dry-run -n utility-release --namespace utility  -f ../values-uat-us-govcloud-global.yaml -f values-uat-us-govcloud.yaml .

# To install
helm install utility-release --namespace utility  -f ../values-uat-us-govcloud-global.yaml -f values-uat-us-govcloud.yaml .

# To purge the release
helm uninstall -n utility utility-release

# To run upgrade.
helm diff upgrade utility-release --namespace utility  -f ../values-uat-us-govcloud-global.yaml -f values-uat-us-govcloud.yaml .
# make sure only your changes are there then run
helm upgrade utility-release --namespace utility  -f ../values-uat-us-govcloud-global.yaml -f values-uat-us-govcloud.yaml .

````

Once the vault pod is running, initialise the vault with following commands
`kubectl exec -it -n utility utility-release-vault-0 -- ash`
````
vault operator init
vault operator unseal <key_1>
vault operator unseal <key_2>
vault operator unseal <key_3>
vault status

#OUTPUT
#Key             Value
#---             -----
#Seal Type       shamir
#Initialized     true
#Sealed          false
#Total Shares    5
#Threshold       3
#Version         1.5.4
#Cluster Name    vault-cluster-5a7a851e
#Cluster ID      a7715181-ef94-9c6b-e8f7-437ab9dd2132
#HA Enabled      false
````

Unseal Key 1: sFFsV4WrduLx9Q+eUp6AkWq3y4TDFGmzX4R32Nhlyus/
Unseal Key 2: GdYyubJ3dNvGQlGWmjeLmwZiHDmqig+qE3CLRaNOJWZ2
Unseal Key 3: fznNj7ENi43Q0Ne4QMD2UfkWEKVVuQZiL4KA97NOnEyl
Unseal Key 4: KGqjY4hxzGK0iHO6Dd3nd79mhJK2YDXZc1A3natyv2vD
Unseal Key 5: R1TFHO9OpOD00aPvMFqPpbv86KvmY9sFGWlsZxshd4nH

Initial Root Token: s.pXeidvipJ1Deo6rmZaum3yKJ

Refer: https://www.hashicorp.com/blog/announcing-the-vault-helm-chart

Okta OIDC setup

TEST_OG_ALCYON_VAULT_NEO
0oavnqe00fE0k96VJ0h7
DSDad4uYWK0kZfpBS7JmXj2ep5jgnrsbPgq-BDPu


path "secret/*" {
capabilities = ["create", "read", "update", "delete", "list"]
}

## Migration Chart

````
cd migration-chart

kubectl create secret generic mongo-secret --from-literal=MONGO_PASSWORD='XXXX' -n migration
kubectl create secret generic migration-secret --from-literal=ORACLE_PASSWORD='XXXX' --from-literal=ALCYON_SERVICE_PASSWORD='XXXX' --from-literal=SIDEKIQ_USERNAME='XXXX' --from-literal=SIDEKIQ_PASSWORD='XXXX' -n migration

helm template -f ../values-uat-us-govcloud-global.yaml  -f values-uat-us-govcloud-lametro.yaml . -n migration-release --namespace migration > test.yaml

helm install --debug --dry-run -n migration-release --namespace migration -f ../values-uat-us-govcloud-global.yaml  -f values-uat-us-govcloud-lametro.yaml .

# To install
helm install migration-release --namespace migration -f ../values-uat-us-govcloud-global.yaml  -f values-uat-us-govcloud-lametro.yaml .

# To purge the release
helm uninstall -n migration migration-release

# To run upgrade.
helm diff upgrade migration-release --namespace migration -f ../values-uat-us-govcloud-global.yaml  -f values-uat-us-govcloud-lametro.yaml .
# make sure only your changes are there then run
helm upgrade migration-release --namespace migration -f ../values-uat-us-govcloud-global.yaml  -f values-uat-us-govcloud-lametro.yaml .

````

## ARM Chart

````
cd arm-chart

kubectl create secret docker-registry regsecret --docker-server=docker.rtsprod.net  --docker-username=redflex --docker-password=XXX --docker-email=cst@redflex.com -n arm
kubectl create secret generic arm-secret --from-literal=DATASOURCE_PASSWORD='XXXX' -n arm

helm template  -f ../values-uat-us-govcloud-global.yaml -f values-uat-us-govcloud.yaml . -n arm-release --namespace arm > test.yaml

helm install --debug --dry-run -n arm-release --namespace arm  -f ../values-uat-us-govcloud-global.yaml -f values-uat-us-govcloud.yaml .

# To install
helm install arm-release --namespace arm  -f ../values-uat-us-govcloud-global.yaml -f values-uat-us-govcloud.yaml .

# To purge the release
helm uninstall -n arm arm-release

# To run upgrade.
helm diff upgrade arm-release --namespace arm  -f ../values-uat-us-govcloud-global.yaml -f values-uat-us-govcloud.yaml .
# make sure only your changes are there then run
helm upgrade arm-release --namespace arm  -f ../values-uat-us-govcloud-global.yaml -f values-uat-us-govcloud.yaml .

````

## Alcyon Field Services Chart

You need to manually create alcyon-fs-secret with the following keys (refer to "create-secret.md"):
- DB_PASSWORD

Then use the following commands to set up the chart

````
cd field-service-chart

kubectl create secret docker-registry regsecret --docker-server=docker.rtsprod.net  --docker-username=redflex --docker-password=XXX --docker-email=ges@redflex.com -n alcyon-fs
kubectl create secret generic alcyon-fs-secret --from-literal=DB_PASSWORD='XXXX' -n alcyon-fs

helm template -f ../values-uat-us-govcloud-global.yaml -f values-uat-us-govcloud.yaml . -n alcyon-fs-release --namespace alcyon-fs > test.yaml

helm install --debug --dry-run -n alcyon-fs-release --namespace alcyon-fs -f ../values-uat-us-govcloud-global.yaml -f values-uat-us-govcloud.yaml .

# To install
helm install alcyon-fs-release --namespace alcyon-fs -f ../values-uat-us-govcloud-global.yaml -f values-uat-us-govcloud.yaml .

# To purge the release
helm uninstall -n alcyon-fs alcyon-fs-release

# To upgrade.
helm diff upgrade alcyon-fs-release --namespace alcyon-fs -f ../values-uat-us-govcloud-global.yaml -f values-uat-us-govcloud.yaml .
# make sure only your changes are there then run
helm upgrade alcyon-fs-release --namespace alcyon-fs -f ../values-uat-us-govcloud-global.yaml -f values-uat-us-govcloud.yaml .

````

## Alcyon Control Chart

````
cd alcyon-control-chart
helm dependency update
kubectl create secret docker-registry regsecret --docker-server=docker.rtsprod.net --docker-username=redflex --docker-password=XXXX --docker-email=cst@redflex.com  -n alcyon-control

kubectl create secret generic alcyon-control-secret --from-literal=GOVERNR_DB_PASSWORD='XXXX' -n alcyon-control

helm template -f ../values-uat-us-govcloud-global.yaml -f values-uat-us-govcloud.yaml . -n alcyon-control-release --namespace alcyon-control > test.yaml

helm install --debug --dry-run -n alcyon-control-release --namespace alcyon-control  -f ../values-uat-us-govcloud-global.yaml -f values-uat-us-govcloud.yaml .

# To install
helm install alcyon-control-release --namespace alcyon-control  -f ../values-uat-us-govcloud-global.yaml -f values-uat-us-govcloud.yaml .

# To purge the release
helm uninstall -n alcyon-control alcyon-control-release

# To upgrade.
helm diff upgrade alcyon-control-release --namespace alcyon-control  -f ../values-uat-us-govcloud-global.yaml -f values-uat-us-govcloud.yaml .
# make sure only your changes are there then run
helm upgrade alcyon-control-release --namespace alcyon-control  -f ../values-uat-us-govcloud-global.yaml -f values-uat-us-govcloud.yaml .
````


## Troubleshooting

1. Network policy
until network policy is sorted for EKS, delete the policies to get the cluster working
````
kubectl delete networkpolicy --all --all-namespaces
````
