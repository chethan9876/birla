# Helm chart installation instruction for MR-BEAN EKS cluster

## Cluster login setup

1. Run the kubernetes-tools container on the admin box.
`docker run -it --rm -v /usr/share/redflex/redflex-helm-charts/:/data/ dockerp.rtsprod.net/common/aws-kubernetes-tools:latest`

2. Setup Kubectl context 
`aws eks --region us-west-2 update-kubeconfig --name tst-mr-bean-eks --profile default`

3. In case you need a public IP you can run this from command line:
`curl -s https://www.showmyip.com/ | grep -oPm1 "(?<=<h2 id=\"ipv4\">)[^<]+"`
## Instalation

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
    kubectl label namespace/alcyon-app name=alcyon-app 
   
    kubectl create ns utility 
    kubectl label namespace/utility name=utility  
    
    kubectl create ns migration  
    kubectl label namespace/migration name=migration  
    
    kubectl create ns arm  
    kubectl label namespace/arm name=arm  
    
    kubectl create ns alcyon-fs 
    kubectl label namespace/alcyon-fs name=alcyon-fs 
    
    kubectl create ns stub 
    kubectl label namespace/stub name=stub 

    kubectl label namespace/default name=default 
    kubectl label namespace/kube-system name=kube-system  
    
    kubectl create ns arm
    kubectl label namespace/arm name=arm
    
    kubectl create ns calgary
    kubectl label namespace/calgary name=calgary
    
    kubectl create ns alcyon-control
    kubectl label namespace/alcyon-control name=alcyon-control
    
    kubectl create ns us
    kubectl label namespace/us name=us
    
    kubectl create ns nsw
    kubectl label namespace/nsw name=nsw
    
    kubectl create ns ca
    kubectl label namespace/ca name=ca
    
    kubectl create ns ca-sk
    kubectl label namespace/ca-sk name=ca-sk
    ````
     
3. Setup the image pull secret in all namespaces
    ````
    kubectl create secret docker-registry regsecret --docker-server=docker.rtsprod.net --docker-username=<username> --docker-password=<password> --docker-email=cst@redflex.com.au -n <namespace>
    
    #eg., 
    kubectl create secret docker-registry regsecret --docker-server=dockerp.rtsprod.net --docker-username=redflex --docker-password=XXX --docker-email=cst@redflex.com -n alcyon-app
    kubectl create secret docker-registry regsecret --docker-server=dockerp.rtsprod.net --docker-username=redflex --docker-password=XXX --docker-email=cst@redflex.com -n alcyon-control
    kubectl create secret docker-registry regsecret --docker-server=dockerp.rtsprod.net --docker-username=redflex --docker-password=XXX --docker-email=cst@redflex.com -n alcyon-fs
    kubectl create secret docker-registry regsecret --docker-server=dockerp.rtsprod.net --docker-username=redflex --docker-password=XXX --docker-email=cst@redflex.com -n us
    kubectl create secret docker-registry regsecret --docker-server=dockerp.rtsprod.net --docker-username=redflex --docker-password=XXX --docker-email=cst@redflex.com -n nsw
    kubectl create secret docker-registry regsecret --docker-server=dockerp.rtsprod.net --docker-username=redflex --docker-password=XXX --docker-email=cst@redflex.com -n ca
    kubectl create secret docker-registry regsecret --docker-server=dockerp.rtsprod.net --docker-username=redflex --docker-password=XXX --docker-email=cst@redflex.com -n ca-sk
    kubectl create secret docker-registry regsecret --docker-server=dockerp.rtsprod.net --docker-username=redflex --docker-password=XXX --docker-email=cst@redflex.com -n calgary
    kubectl create secret docker-registry regsecret --docker-server=dockerp.rtsprod.net --docker-username=redflex --docker-password=XXX --docker-email=cst@redflex.com -n arm
    kubectl create secret docker-registry regsecret --docker-server=dockerp.rtsprod.net --docker-username=redflex --docker-password=XXX --docker-email=cst@redflex.com -n migration
    kubectl create secret docker-registry regsecret --docker-server=dockerp.rtsprod.net --docker-username=redflex --docker-password=XXX --docker-email=cst@redflex.com -n utility
    kubectl create secret docker-registry regsecret --docker-server=dockerp.rtsprod.net --docker-username=redflex --docker-password=XXX --docker-email=cst@redflex.com -n stub
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

helm template eks-release -n kube-system -f ../values-tst-mr-bean-global.yaml -f values-tst-mr-bean.yaml . > test.yaml

# To install
helm install eks-release  --namespace kube-system  -f ../values-tst-mr-bean-global.yaml -f values-tst-mr-bean.yaml .


# To upgrade the chart
helm diff upgrade eks-release --namespace kube-system  -f ../values-tst-mr-bean-global.yaml -f values-tst-mr-bean.yaml .
# make sure only your changes are there then run
helm upgrade eks-release --namespace kube-system  -f ../values-tst-mr-bean-global.yaml -f values-tst-mr-bean.yaml .

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

helm template base-release -n base -f ../values-tst-mr-bean-global.yaml -f values-tst-mr-bean.yaml . > test.yaml

# To install
helm install base-release  --namespace base  -f ../values-tst-mr-bean-global.yaml -f values-tst-mr-bean.yaml .

# To upgrade the chart.
helm diff upgrade base-release --namespace base -f ../values-tst-mr-bean-global.yaml -f values-tst-mr-bean.yaml .
# make sure only your changes are there then run
helm upgrade base-release --namespace base -f ../values-tst-mr-bean-global.yaml -f values-tst-mr-bean.yaml .

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

helm template monitoring-release  -f ../values-tst-mr-bean-global.yaml -f values-tst-mr-bean.yaml -n monitoring . > test.yaml

# To install
helm install monitoring-release -n monitoring  -f ../values-tst-mr-bean-global.yaml -f values-tst-mr-bean.yaml .

# To upgrade the chart when new subchart is added.
helm diff upgrade monitoring-release -n monitoring   -f ../values-tst-mr-bean-global.yaml -f values-tst-mr-bean.yaml .
# make sure only your changes are there then run
helm upgrade monitoring-release -n monitoring   -f ../values-tst-mr-bean-global.yaml -f values-tst-mr-bean.yaml .

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

helm template . -n alcyon-release  -f ../values-tst-mr-bean-global.yaml -f values-tst-mr-bean.yaml --namespace alcyon-app > test.yaml

helm install --debug --dry-run alcyon-release -n alcyon-app  -f ../values-tst-mr-bean-global.yaml -f values-tst-mr-bean.yaml .

# To install
helm install alcyon-release -n alcyon-app  -f ../values-tst-mr-bean-global.yaml -f values-tst-mr-bean.yaml .

# To upgrade the chart
helm diff upgrade alcyon-release -n alcyon-app  -f ../values-tst-mr-bean-global.yaml -f values-tst-mr-bean.yaml .
# make sure only your changes are there then run
helm upgrade alcyon-release -n alcyon-app  -f ../values-tst-mr-bean-global.yaml -f values-tst-mr-bean.yaml .

helm uninstall -n alcyon-app alcyon-release
````

### USA Chart

You need to manually create usa-secret with the following keys
- LEDGR_PASSWORD
- SEEKR_PASSWORD
- SEEKR_WADOL_PASSWORD
- IPAPROCESSR_DB_PASSWORD

You need to manually create recaptcha-secret with the following keys
- sitekey
- secretkey


````
cd usa-chart

helm dependency update

kubectl create secret generic alcyon-secret --from-literal=ALCYON_SERVICE_PASSWORD='XXXX' --from-literal=ALCYON_PORTAL_PASSWORD='XXXX' -n us
kubectl create secret generic usa-secret --from-literal=SEEKR_VAULT_ROLE_ID='XXXX' --from-literal=SEEKR_VAULT_SECRET_ID='XXXX' --from-literal=SEEKR_WADOL_PASSWORD='XXXX  --from-literal=WIZARD_PASSWORD='XXXX' --from-literal=COLLECTR_DB_PASSWORD='XXXX' --from-literal=WIZARD_REPORTS_DB_PASSWORD='XXXX' --from-literal=IPAPROCESSR_DB_PASSWORD='XXXX' -n us
kubectl create secret generic recaptcha-secret --from-literal=sitekey='XXX' --from-literal=secretkey='XXXX'  -n us
kubectl create secret generic wip-queue-stats-secret --from-literal=WIP_QUEUE_STATS_PASSWORD='XXXX' -n us

helm template  -f ../values-tst-mr-bean-global.yaml -f values-tst-mr-bean.yaml . -n usa-release --namespace us > test.yaml

helm install --debug --dry-run -n usa-release --namespace us  -f ../values-tst-mr-bean-global.yaml -f values-tst-mr-bean.yaml .

# To install
helm install usa-release --namespace us  -f ../values-tst-mr-bean-global.yaml -f values-tst-mr-bean.yaml .

# To purge the release
helm uninstall -n us usa-release

# To upgrade.
helm diff upgrade usa-release --namespace us  -f ../values-tst-mr-bean-global.yaml -f values-tst-mr-bean.yaml .
# make sure only your changes are there then run
helm upgrade usa-release --namespace us  -f ../values-tst-mr-bean-global.yaml -f values-tst-mr-bean.yaml .
````

### CA Chart

You need to manually create ca-secret with the following keys
- LEDGR_PASSWORD
- SEEKR_PASSWORD
- CALLBACK_PASSWORD
- ALCYON_SERVICE_PASSWORD

````
cd ca-chart

kubectl create secret generic ca-secret --from-literal=SEEKR_PASSWORD='XXXX' --from-literal=LEDGR_PASSWORD='XXXX' --from-literal=CALLBACK_PASSWORD='XXXX' --from-literal=ALCYON_SERVICE_PASSWORD='XXXX' -n ca

helm template  -f ../values-tst-mr-bean-global.yaml -f values-tst-mr-bean.yaml . -n ca-release --namespace ca > test.yaml

helm install --debug --dry-run -n ca-release --namespace ca -f ../values-tst-mr-bean-global.yaml -f values-tst-mr-bean.yaml .

# To install
helm install ca-release --namespace ca -f ../values-tst-mr-bean-global.yaml -f values-tst-mr-bean.yaml .

# To purge the release
helm uninstall -n ca ca-release

# To upgrade.
helm diff upgrade ca-release --namespace ca -f ../values-tst-mr-bean-global.yaml -f values-tst-mr-bean.yaml .
# make sure only your changes are there then run
helm upgrade ca-release --namespace ca -f ../values-tst-mr-bean-global.yaml -f values-tst-mr-bean.yaml .
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

helm template  -f ../values-tst-mr-bean-global.yaml -f values-tst-mr-bean.yaml . -n utility-release --namespace utility > test.yaml

helm install --debug --dry-run -n utility-release --namespace utility  -f ../values-tst-mr-bean-global.yaml -f values-tst-mr-bean.yaml .

# To install
helm install utility-release --namespace utility  -f ../values-tst-mr-bean-global.yaml -f values-tst-mr-bean.yaml .

# To purge the release
helm uninstall -n utility utility-release

# To run upgrade.
helm diff upgrade utility-release --namespace utility  -f ../values-tst-mr-bean-global.yaml -f values-tst-mr-bean.yaml .
# make sure only your changes are there then run
helm upgrade utility-release --namespace utility  -f ../values-tst-mr-bean-global.yaml -f values-tst-mr-bean.yaml .

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

helm template -f ../values-tst-mr-bean-global.yaml  -f values-tst-mr-bean-lametro.yaml . -n migration-release --namespace migration > test.yaml

helm install --debug --dry-run -n migration-release --namespace migration -f ../values-tst-mr-bean-global.yaml  -f values-tst-mr-bean-lametro.yaml .

# To install
helm install migration-release --namespace migration -f ../values-tst-mr-bean-global.yaml  -f values-tst-mr-bean-lametro.yaml .

# To purge the release
helm uninstall -n migration migration-release

# To run upgrade.
helm diff upgrade migration-release --namespace migration -f ../values-tst-mr-bean-global.yaml  -f values-tst-mr-bean-lametro.yaml .
# make sure only your changes are there then run
helm upgrade migration-release --namespace migration -f ../values-tst-mr-bean-global.yaml  -f values-tst-mr-bean-lametro.yaml .

````

## ARM Chart

````
cd arm-chart

kubectl create secret docker-registry regsecret --docker-server=docker.rtsprod.net  --docker-username=redflex --docker-password=XXX --docker-email=cst@redflex.com -n arm
kubectl create secret generic arm-secret --from-literal=DATASOURCE_PASSWORD='XXXX' -n arm

helm template  -f ../values-tst-mr-bean-global.yaml -f values-tst-mr-bean.yaml . -n arm-release --namespace arm > test.yaml

helm install --debug --dry-run -n arm-release --namespace arm  -f ../values-tst-mr-bean-global.yaml -f values-tst-mr-bean.yaml .

# To install
helm install arm-release --namespace arm  -f ../values-tst-mr-bean-global.yaml -f values-tst-mr-bean.yaml .

# To purge the release
helm uninstall -n arm arm-release

# To run upgrade.
helm diff upgrade arm-release --namespace arm  -f ../values-tst-mr-bean-global.yaml -f values-tst-mr-bean.yaml .
# make sure only your changes are there then run
helm upgrade arm-release --namespace arm  -f ../values-tst-mr-bean-global.yaml -f values-tst-mr-bean.yaml .

````

## NSW Chart


You need to manually create nsw-secret with the following keys (refer to "create-secret.md"):
- ZINCR_ALCYON_REST_PASSWORD
- ZINCR_ITREE_PASSWORD
- ZINCR_EXPORT_PASSWORD

Then use the following commands to set up the chart

````
cd nsw-chart

kubectl create secret generic zincr-secret --from-literal=ZINCR_ALCYON_REST_PASSWORD='XXXX' --from-literal=ZINCR_ITREE_PASSWORD='XXXX' --from-literal=ZINCR_EXPORT_PASSWORD='XXXX' -n nsw
kubectl create secret generic trafficstatsingestr-secret --from-literal=DB_PASSWORD='XXXX' -n nsw

helm template . -n nsw-release  -f ../values-tst-mr-bean-global.yaml -f values-tst-mr-bean.yaml --namespace nsw > test.yaml

helm install --debug --dry-run nsw-release -n nsw  -f ../values-tst-mr-bean-global.yaml -f values-tst-mr-bean.yaml .

# To install
helm install nsw-release -n nsw  -f ../values-tst-mr-bean-global.yaml -f values-tst-mr-bean.yaml .

# To view diff before upgrade .
helm diff upgrade nsw-release -n nsw  -f ../values-tst-mr-bean-global.yaml -f values-tst-mr-bean.yaml .

# To upgrade the chart
helm upgrade nsw-release -n nsw  -f ../values-tst-mr-bean-global.yaml -f values-tst-mr-bean.yaml .

helm uninstall -n nsw nsw-release
````

## Stub Chart

````
cd stub-chart

kubectl create secret docker-registry regsecret --docker-server=docker.rtsprod.net  --docker-username=redflex --docker-password=XXX --docker-email=cst@redflex.com -n stub

helm template  -f ../values-tst-mr-bean-global.yaml -f values-tst-mr-bean.yaml . -n stub-release --namespace stub > test.yaml

helm install --debug --dry-run -n stub-release --namespace stub  -f ../values-tst-mr-bean-global.yaml -f values-tst-mr-bean.yaml .

# To install
helm install stub-release --namespace stub  -f ../values-tst-mr-bean-global.yaml -f values-tst-mr-bean.yaml .

# To purge the release
helm uninstall -n stub stub-release

# To run upgrade.
helm diff upgrade stub-release --namespace stub  -f ../values-tst-mr-bean-global.yaml -f values-tst-mr-bean.yaml .
# make sure only your changes are there then run
helm upgrade stub-release --namespace stub  -f ../values-tst-mr-bean-global.yaml -f values-tst-mr-bean.yaml .

````

## Alcyon Field Services Chart

You need to manually create alcyon-fs-secret with the following keys (refer to "create-secret.md"):
- DB_PASSWORD

Then use the following commands to set up the chart

````
cd field-service-chart

kubectl create secret docker-registry regsecret --docker-server=docker.rtsprod.net  --docker-username=redflex --docker-password=XXX --docker-email=ges@redflex.com -n alcyon-fs
kubectl create secret generic alcyon-fs-secret --from-literal=DB_PASSWORD='XXXX' -n alcyon-fs

helm template -f ../values-tst-mr-bean-global.yaml -f values-tst-mr-bean.yaml . -n alcyon-fs-release --namespace alcyon-fs > test.yaml

helm install --debug --dry-run -n alcyon-fs-release --namespace alcyon-fs -f ../values-tst-mr-bean-global.yaml -f values-tst-mr-bean.yaml .

# To install
helm install alcyon-fs-release --namespace alcyon-fs -f ../values-tst-mr-bean-global.yaml -f values-tst-mr-bean.yaml .

# To purge the release
helm uninstall -n alcyon-fs alcyon-fs-release

# To upgrade.
helm diff upgrade alcyon-fs-release --namespace alcyon-fs -f ../values-tst-mr-bean-global.yaml -f values-tst-mr-bean.yaml .
# make sure only your changes are there then run
helm upgrade alcyon-fs-release --namespace alcyon-fs -f ../values-tst-mr-bean-global.yaml -f values-tst-mr-bean.yaml .

````

## Alcyon Control Chart

````
cd alcyon-control-chart
helm dependency update
kubectl create secret docker-registry regsecret --docker-server=docker.rtsprod.net --docker-username=redflex --docker-password=XXXX --docker-email=cst@redflex.com  -n alcyon-control

kubectl create secret generic alcyon-control-secret --from-literal=GOVERNR_DB_PASSWORD='XXXX' -n alcyon-control

helm template -f ../values-tst-mr-bean-global.yaml -f values-tst-mr-bean.yaml . -n alcyon-control-release --namespace alcyon-control > test.yaml

helm install --debug --dry-run -n alcyon-control-release --namespace alcyon-control  -f ../values-tst-mr-bean-global.yaml -f values-tst-mr-bean.yaml .

# To install
helm install alcyon-control-release --namespace alcyon-control  -f ../values-tst-mr-bean-global.yaml -f values-tst-mr-bean.yaml .

# To purge the release
helm uninstall -n alcyon-control alcyon-control-release

# To upgrade.
helm diff upgrade alcyon-control-release --namespace alcyon-control  -f ../values-tst-mr-bean-global.yaml -f values-tst-mr-bean.yaml .
# make sure only your changes are there then run
helm upgrade alcyon-control-release --namespace alcyon-control  -f ../values-tst-mr-bean-global.yaml -f values-tst-mr-bean.yaml .
````

## Calgary Chart

````
cd calgary-chart
helm dependency update
kubectl create secret docker-registry regsecret --docker-server=docker.rtsprod.net --docker-username=redflex --docker-password=XXXX --docker-email=cst@redflex.com  -n calgary

kubectl create secret generic calgarytransformr-secret --from-literal=DB_PASSWORD=XXXXX --from-literal=CAL_SFTP_PASSWORD=XXXXX -n calgary


helm template -f ../values-tst-mr-bean-global.yaml -f values-tst-mr-bean.yaml . -n calgary-release --namespace calgary > test.yaml

helm install --debug --dry-run -n calgary-release --namespace calgary  -f ../values-tst-mr-bean-global.yaml -f values-tst-mr-bean.yaml .

# To install
helm install calgary-release --namespace calgary  -f ../values-tst-mr-bean-global.yaml -f values-tst-mr-bean.yaml .

# To purge the release
helm uninstall -n calgary calgary-release

# To upgrade.
helm diff upgrade calgary-release --namespace calgary  -f ../values-tst-mr-bean-global.yaml -f values-tst-mr-bean.yaml .
# make sure only your changes are there then run
helm upgrade calgary-release --namespace calgary  -f ../values-tst-mr-bean-global.yaml -f values-tst-mr-bean.yaml .
````

### CA-SK Chart

````
cd ca-sk-chart

kubectl create secret generic ca-sk-secret --from-literal=SEEKR_PASSWORD='XXXX' --from-literal=LEDGR_PASSWORD='XXXX' --from-literal=CALLBACK_PASSWORD="XXXX" --from-literal=ALCYON_SERVICE_PASSWORD='XXXX' --from-literal=ALCYON_PORTAL_PASSWORD='XXXX' -n ca-sk

kubectl create secret generic recaptcha-secret --from-literal=sitekey='XXXX' --from-literal=secretkey='XXXX' -n ca-sk

kubectl create secret generic s3-secret --from-literal=accesskey='XXXX' --from-literal=secretkey='XXXX' -n ca-sk

helm template -f ../values-tst-mr-bean-global.yaml  -f values-tst-mr-bean.yaml . -n ca-sk-release --namespace ca-sk > test.yaml

helm install --debug --dry-run -n ca-sk-release --namespace ca-sk -f ../values-tst-mr-bean-global.yaml  -f values-tst-mr-bean.yaml .

# To install
helm install ca-sk-release --namespace ca-sk -f ../values-tst-mr-bean-global.yaml  -f values-tst-mr-bean.yaml .

# To purge the release
helm uninstall -n ca-sk ca-sk-release

# To upgrade.
helm diff upgrade ca-sk-release --namespace ca-sk -f ../values-tst-mr-bean-global.yaml  -f values-tst-mr-bean.yaml .
# make sure only your changes are there then run
helm upgrade ca-sk-release --namespace ca-sk -f ../values-tst-mr-bean-global.yaml  -f values-tst-mr-bean.yaml .
````




## Temproary Upgrade environment used for PEGA 8

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

kubectl create secret generic alcyon-secret --from-literal=DB_PASSWORD='XXXX' --from-literal=DB_RO_PASSWORD='XXXX' --from-literal=ALCYON_SERVICE_PASSWORD='XXXX' --from-literal=ALCYON_PORTAL_PASSWORD='XXXX' -n upgrade

# S3 secret for FieldService
kubectl create secret generic s3-secret --from-literal=accesskey='XXXX' --from-literal=secretkey='XXXX' -n upgrade
# archive secret
kubectl create secret generic archive-secret --from-literal=accesskey='XXXX' --from-literal=secretkey='XXXX' -n upgrade

helm template . -n alcyon-upgrade-release  -f ../values-tst-mr-bean-upgrade-global.yaml -f values-tst-mr-bean-upgrade.yaml --namespace upgrade > test.yaml

helm install --debug --dry-run alcyon-upgrade-release -n upgrade  -f ../values-tst-mr-bean-upgrade-global.yaml -f values-tst-mr-bean-upgrade.yaml .

# To install
helm install alcyon-upgrade-release -n upgrade  -f ../values-tst-mr-bean-upgrade-global.yaml -f values-tst-mr-bean-upgrade.yaml .

# To upgrade the chart
helm diff upgrade alcyon-upgrade-release -n upgrade  -f ../values-tst-mr-bean-upgrade-global.yaml -f values-tst-mr-bean-upgrade.yaml .
# make sure only your changes are there then run
helm upgrade alcyon-upgrade-release -n upgrade  -f ../values-tst-mr-bean-upgrade-global.yaml -f values-tst-mr-bean-upgrade.yaml .

helm uninstall -n upgrade alcyon-upgrade-release
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

kubectl create secret generic alcyon-secret --from-literal=ALCYON_SERVICE_PASSWORD='XXXX' --from-literal=ALCYON_PORTAL_PASSWORD='XXXX' -n upgrade
kubectl create secret generic usa-secret --from-literal=SEEKR_VAULT_ROLE_ID='XXXX' --from-literal=SEEKR_VAULT_SECRET_ID='XXXX' --from-literal=SEEKR_WADOL_PASSWORD='XXXX  --from-literal=WIZARD_PASSWORD='XXXX' --from-literal=COLLECTR_DB_PASSWORD='XXXX' --from-literal=WIZARD_REPORTS_DB_PASSWORD='XXXX' -n upgrade
kubectl create secret generic recaptcha-secret --from-literal=sitekey='XXX' --from-literal=secretkey='XXXX'  -n upgrade
kubectl create secret generic wip-queue-stats-secret --from-literal=WIP_QUEUE_STATS_PASSWORD='XXXX' -n upgrade

helm template  -f ../values-tst-mr-bean-upgrade-global.yaml -f values-tst-mr-bean-upgrade.yaml . -n usa-upgrade-release --namespace upgrade > test.yaml

helm install --debug --dry-run -n usa-upgrade-release --namespace upgrade -f ../values-tst-mr-bean-upgrade-global.yaml -f values-tst-mr-bean-upgrade.yaml .

# To install
helm install usa-upgrade-release --namespace upgrade -f ../values-tst-mr-bean-upgrade-global.yaml -f values-tst-mr-bean-upgrade.yaml .

# To purge the release
helm uninstall -n upgrade usa-upgrade-release

# To upgrade.
helm diff upgrade usa-upgrade-release --namespace upgrade -f ../values-tst-mr-bean-upgrade-global.yaml -f values-tst-mr-bean-upgrade.yaml .
# make sure only your changes are there then run
helm upgrade usa-upgrade-release --namespace upgrade -f ../values-tst-mr-bean-upgrade-global.yaml -f values-tst-mr-bean-upgrade.yaml .
````

### CA Chart

You need to manually create ca-secret with the following keys
- LEDGR_PASSWORD
- SEEKR_PASSWORD
- CALLBACK_PASSWORD
- ALCYON_SERVICE_PASSWORD

````
cd ca-chart

kubectl create secret generic ca-secret --from-literal=SEEKR_PASSWORD='XXXX' --from-literal=LEDGR_PASSWORD='XXXX' --from-literal=CALLBACK_PASSWORD='XXXX' --from-literal=ALCYON_SERVICE_PASSWORD='XXXX' -n upgrade

helm template  -f ../values-tst-mr-bean-upgrade-global.yaml -f values-tst-mr-bean-upgrade.yaml . -n ca-upgrade-release --namespace upgrade > test.yaml

helm install --debug --dry-run ca-upgrade-release --namespace upgrade -f ../values-tst-mr-bean-upgrade-global.yaml -f values-tst-mr-bean-upgrade.yaml .

# To install
helm install ca-upgrade-release --namespace upgrade -f ../values-tst-mr-bean-upgrade-global.yaml -f values-tst-mr-bean-upgrade.yaml .

# To purge the release
helm uninstall -n upgrade ca-upgrade-release

# To upgrade.
helm diff upgrade ca-upgrade-release --namespace upgrade -f ../values-tst-mr-bean-upgrade-global.yaml -f values-tst-mr-bean-upgrade.yaml .
# make sure only your changes are there then run
helm upgrade ca-upgrade-release --namespace upgrade -f ../values-tst-mr-bean-upgrade-global.yaml -f values-tst-mr-bean-upgrade.yaml .
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

helm template  -f ../values-tst-mr-bean-upgrade-global.yaml -f values-tst-mr-bean-upgrade.yaml . -n utility-upgrade-release --namespace upgrade > test.yaml

helm install --debug --dry-run -n utility-upgrade-release --namespace upgrade  -f ../values-tst-mr-bean-upgrade-global.yaml -f values-tst-mr-bean-upgrade.yaml .

# To install
helm install utility-upgrade-release --namespace upgrade  -f ../values-tst-mr-bean-upgrade-global.yaml -f values-tst-mr-bean-upgrade.yaml .

# To purge the release
helm uninstall -n upgrade utility-upgrade-release

# To run upgrade.
helm diff upgrade utility-upgrade-release --namespace upgrade  -f ../values-tst-mr-bean-upgrade-global.yaml -f values-tst-mr-bean-upgrade.yaml .
# make sure only your changes are there then run
helm upgrade utility-upgrade-release --namespace upgrade  -f ../values-tst-mr-bean-upgrade-global.yaml -f values-tst-mr-bean-upgrade.yaml .

````


## Migration Chart

````
cd migration-chart

kubectl create secret generic mongo-secret --from-literal=MONGO_PASSWORD='XXXX' -n migration
kubectl create secret generic migration-secret --from-literal=ORACLE_PASSWORD='XXXX' --from-literal=ALCYON_SERVICE_PASSWORD='XXXX' --from-literal=SIDEKIQ_USERNAME='XXXX' --from-literal=SIDEKIQ_PASSWORD='XXXX' -n migration

helm template -f ../values-tst-mr-bean-upgrade-global.yaml  -f values-tst-mr-bean-upgrade-lametro.yaml . -n migration-upgrade-release --namespace upgrade > test.yaml

helm install --debug --dry-run -n migration-upgrade-release --namespace upgrade -f ../values-tst-mr-bean-upgrade-global.yaml  -f values-tst-mr-bean-upgrade-lametro.yaml .

# To install
helm install migration-upgrade-release --namespace upgrade -f ../values-tst-mr-bean-upgrade-global.yaml  -f values-tst-mr-bean-upgrade-lametro.yaml .

# To purge the release
helm uninstall -n upgrade migration-upgrade-release

# To run upgrade.
helm diff upgrade migration-upgrade-release --namespace upgrade -f ../values-tst-mr-bean-upgrade-global.yaml  -f values-tst-mr-bean-upgrade-lametro.yaml .
# make sure only your changes are there then run
helm upgrade migration-upgrade-release --namespace upgrade -f ../values-tst-mr-bean-upgrade-global.yaml  -f values-tst-mr-bean-upgrade-lametro.yaml .

````

## ARM Chart

````
cd arm-chart

kubectl create secret docker-registry regsecret --docker-server=docker.rtsprod.net  --docker-username=redflex --docker-password=XXX --docker-email=cst@redflex.com -n arm
kubectl create secret generic arm-secret --from-literal=DATASOURCE_PASSWORD='XXXX' -n arm

helm template  -f ../values-tst-mr-bean-upgrade-global.yaml -f values-tst-mr-bean-upgrade.yaml . -n arm-upgrade-release --namespace upgrade > test.yaml

helm install --debug --dry-run -n arm-upgrade-release --namespace upgrade  -f ../values-tst-mr-bean-upgrade-global.yaml -f values-tst-mr-bean-upgrade.yaml .

# To install
helm install arm-upgrade-release --namespace upgrade  -f ../values-tst-mr-bean-upgrade-global.yaml -f values-tst-mr-bean-upgrade.yaml .

# To purge the release
helm uninstall -n upgrade arm-upgrade-release

# To run upgrade.
helm diff upgrade arm-upgrade-release --namespace upgrade  -f ../values-tst-mr-bean-upgrade-global.yaml -f values-tst-mr-bean-upgrade.yaml .
# make sure only your changes are there then run
helm upgrade arm-upgrade-release --namespace upgrade  -f ../values-tst-mr-bean-upgrade-global.yaml -f values-tst-mr-bean-upgrade.yaml .

````
## Stub Chart

````
cd stub-chart

kubectl create secret docker-registry regsecret --docker-server=docker.rtsprod.net  --docker-username=redflex --docker-password=XXX --docker-email=cst@redflex.com -n stub

helm template  -f ../values-tst-mr-bean-upgrade-global.yaml -f values-tst-mr-bean-upgrade.yaml . -n stub-upgrade-release --namespace upgrade > test.yaml

helm install --debug --dry-run -n stub-upgrade-release --namespace upgrade  -f ../values-tst-mr-bean-upgrade-global.yaml -f values-tst-mr-bean-upgrade.yaml .

# To install
helm install stub-upgrade-release --namespace upgrade  -f ../values-tst-mr-bean-upgrade-global.yaml -f values-tst-mr-bean-upgrade.yaml .

# To purge the release
helm uninstall -n upgrade stub-upgrade-release

# To run upgrade.
helm diff upgrade stub-upgrade-release --namespace upgrade  -f ../values-tst-mr-bean-upgrade-global.yaml -f values-tst-mr-bean-upgrade.yaml .
# make sure only your changes are there then run
helm upgrade stub-upgrade-release --namespace upgrade  -f ../values-tst-mr-bean-upgrade-global.yaml -f values-tst-mr-bean-upgrade.yaml .

````





## Troubleshooting

1. Network policy
until network policy is sorted for EKS, delete the policies to get the cluster working
````
kubectl delete networkpolicy --all --all-namespaces
````
