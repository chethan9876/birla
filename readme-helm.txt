Helm chart installation instruction for AU-WA EKS cluster
Cluster login setup
Run the kubernetes-tools container on the admin box. docker run -it --rm -v /usr/share/redflex/redflex-helm-charts/:/data/ dockerp.rtsprod.net/common/aws-kubernetes-tools:latest

Setup Kubectl context aws eks --region ap-southeast-2 update-kubeconfig --name stg-au-wa-eks --profile au-wa

In case you need a public IP you can run this from command line: curl -s https://www.showmyip.com/ | grep -oPm1 "(?<=<h2 id=\"ipv4\">)[^<]+"

Instalation
Setup namespaces
NOTE: Calico policies work based on namespace labels. Adding labels are mandatory.

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

kubectl create ns au-wa
kubectl label namespace/au-wa name=au-wa

kubectl label namespace/default name=default 
kubectl label namespace/kube-system name=kube-system
Setup the image pull secret in all namespaces
kubectl create secret docker-registry regsecret --docker-server=docker.rtsprod.net --docker-username=<username> --docker-password=<password> --docker-email=cst@redflex.com.au -n <namespace>

#eg., 
kubectl create secret docker-registry regsecret --docker-server=dockerp.rtsprod.net --docker-username=redflex --docker-password=XXX --docker-email=cst@redflex.com -n au-wa
kubectl create secret docker-registry regsecret --docker-server=dockerp.rtsprod.net --docker-username=redflex --docker-password=XXX --docker-email=cst@redflex.com -n arm
kubectl create secret docker-registry regsecret --docker-server=dockerp.rtsprod.net --docker-username=redflex --docker-password=XXX --docker-email=cst@redflex.com -n migration
kubectl create secret docker-registry regsecret --docker-server=dockerp.rtsprod.net --docker-username=redflex --docker-password=XXX --docker-email=cst@redflex.com -n utility
    kubectl create secret docker-registry regsecret --docker-server=dockerp.rtsprod.net --docker-username=redflex --docker-password=XXX --docker-email=cst@redflex.com -n stub
Deploy
EKS chart
# run following first time only:
kubectl annotate ConfigMap aws-auth -n kube-system meta.helm.sh/release-namespace=kube-system
kubectl annotate ConfigMap aws-auth -n kube-system meta.helm.sh/release-name=eks-release
kubectl label ConfigMap aws-auth -n kube-system app.kubernetes.io/managed-by=Helm

# To purge the release
helm uninstall -n kube-system eks-release 

helm template eks-release -n kube-system -f ../values-stg-au-wa-global.yaml -f values-stg-au-wa.yaml . > test.yaml

# To install
helm install eks-release  --namespace kube-system  -f ../values-stg-au-wa-global.yaml -f values-stg-au-wa.yaml .


# To upgrade the chart
helm diff upgrade eks-release --namespace kube-system  -f ../values-stg-au-wa-global.yaml -f values-stg-au-wa.yaml .
# make sure only your changes are there then run
helm upgrade eks-release --namespace kube-system  -f ../values-stg-au-wa-global.yaml -f values-stg-au-wa.yaml .

# To verify status
helm status eks-release -n kube-system 
Base chart
Prerequisite: AWS Subnets need to be tagged with the following value to allow nginx-ingress to create ELB automatically.

For public subnet - kubernetes.io/role/elb - 1 For private subnet - kubernetes.io/role/internal-elb - 1 and cluster name should be tagged kubernetes.io/cluster/neo-rts-onl-cluster - shared

 
# To purge the release
helm uninstall -n base base-release 

helm repo add  alb https://aws.github.io/eks-charts
helm dependency update
kubectl apply -k "github.com/aws/eks-charts/stable/aws-load-balancer-controller/crds?ref=master"

helm template base-release -n base -f ../values-stg-au-wa-global.yaml -f values-stg-au-wa.yaml . > test.yaml

# To install
helm install base-release  --namespace base  -f ../values-stg-au-wa-global.yaml -f values-stg-au-wa.yaml .

# To upgrade the chart.
helm diff upgrade base-release --namespace base -f ../values-stg-au-wa-global.yaml -f values-stg-au-wa.yaml .
# make sure only your changes are there then run
helm upgrade base-release --namespace base -f ../values-stg-au-wa-global.yaml -f values-stg-au-wa.yaml .

# To verify status
helm status base-release
Monitoring chart
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

helm template monitoring-release  -f ../values-stg-au-wa-global.yaml -f values-stg-au-wa.yaml -n monitoring . > test.yaml

# To install
helm install monitoring-release -n monitoring  -f ../values-stg-au-wa-global.yaml -f values-stg-au-wa.yaml .

# To upgrade the chart when new subchart is added.
helm diff upgrade monitoring-release -n monitoring   -f ../values-stg-au-wa-global.yaml -f values-stg-au-wa.yaml .
# make sure only your changes are there then run
helm upgrade monitoring-release -n monitoring   -f ../values-stg-au-wa-global.yaml -f values-stg-au-wa.yaml .

# To verify status
helm status monitoring-release

kubectl delete crd  viziers.px.dev
helm uninstall -n monitoring monitoring-release
Once helm chart is deployed, follow the steps in monitoring-chart/README.md file.

Alcyon Chart
You need to manually create alcyon-secret with the following keys:

DB_PASSWORD
DB_RO_PASSWORD
ALCYON_SERVICE_PASSWORD
ALCYON_PORTAL_PASSWORD
and s3-secret with the following keys:

accesskey
secretkey
Then use the following commands to set up the chart

cd alcyon_chart

kubectl create secret generic alcyon-secret --from-literal=DB_PASSWORD='XXXX' --from-literal=DB_RO_PASSWORD='XXXX' --from-literal=ALCYON_SERVICE_PASSWORD='XXXX' --from-literal=ALCYON_PORTAL_PASSWORD='XXXX' --from-literal=KAFKA_PASSWORD='XXXX' -n au-wa

# S3 secret for FieldService
kubectl create secret generic s3-secret --from-literal=accesskey='XXXX' --from-literal=secretkey='XXXX' -n alcyon-app
# archive secret
kubectl create secret generic archive-secret --from-literal=accesskey='XXXX' --from-literal=secretkey='XXXX' -n alcyon-app

helm template . -n alcyon-release  -f ../values-stg-au-wa-global.yaml -f values-stg-au-wa.yaml --namespace alcyon-app > test.yaml

helm install --debug --dry-run alcyon-release -n alcyon-app  -f ../values-stg-au-wa-global.yaml -f values-stg-au-wa.yaml .

# To install
helm install alcyon-release -n alcyon-app  -f ../values-stg-au-wa-global.yaml -f values-stg-au-wa.yaml .

# To upgrade the chart
helm diff upgrade alcyon-release -n alcyon-app  -f ../values-stg-au-wa-global.yaml -f values-stg-au-wa.yaml .
# make sure only your changes are there then run
helm upgrade alcyon-release -n alcyon-app  -f ../values-stg-au-wa-global.yaml -f values-stg-au-wa.yaml .

helm uninstall -n alcyon-app alcyon-release
au-wa Chart
cd au-wa-chart

# S3 secret for au-wa charts
kubectl create secret generic s3-secret --from-literal  =accesskey='XXXX' --from-literal=secretkey='XXXX' -n au-wa

helm template . -n au-wa-release  -f ../values-stg-au-wa-global.yaml -f values-stg-au-wa.yaml --namespace alcyon-app > test.yaml

helm install --debug --dry-run au-wa-release -n au-wa  -f ../values-stg-au-wa-global.yaml -f values-stg-au-wa.yaml .

# To install
helm install au-wa-release -n au-wa  -f ../values-stg-au-wa-global.yaml -f values-stg-au-wa.yaml .

# To upgrade the chart
helm diff upgrade au-wa-release -n au-wa  -f ../values-stg-au-wa-global.yaml -f values-stg-au-wa.yaml .
# make sure only your changes are there then run
helm upgrade au-wa-release -n au-wa  -f ../values-stg-au-wa-global.yaml -f values-stg-au-wa.yaml .

helm uninstall -n au-wa au-wa-release
Utility Chart
Prerequisite: Create a Postgres Schema for Rundeck application.

Refer to Utility Readme file for DB instructions.

cd utility-chart

kubectl create secret docker-registry regsecret --docker-server=dockerp.rtsprod.net --docker-username=redflex --docker-password=redflex --docker-email=cst@redflex.com -n utility
kubectl create secret generic utility-secret --from-literal=RUNDECK_DATABASE_PASSWORD='XXXX' --from-literal=RUNDECK_ALCYON_DB_PASSWORD='XXXX' --from-literal=RUNDECK_ALCYON_ADMIN_PASSWORD='XXXX' --from-literal=BIX_DB_PASSWORD='XXXX' --from-literal=TRAFFIC_STATS_DB_PASSWORD='XXXX' -n utility

helm repo add incubator http://storage.googleapis.com/kubernetes-charts-incubator  
helm dependency update

helm template  -f ../values-stg-au-wa-global.yaml -f values-stg-au-wa.yaml . -n utility-release --namespace utility > test.yaml

helm install --debug --dry-run utility-release --namespace utility  -f ../values-stg-au-wa-global.yaml -f values-stg-au-wa.yaml .

# To install
helm install utility-release --namespace utility  -f ../values-stg-au-wa-global.yaml -f values-stg-au-wa.yaml .

# To purge the release
helm uninstall -n utility utility-release

# To run upgrade.
helm diff upgrade utility-release --namespace utility  -f ../values-stg-au-wa-global.yaml -f values-stg-au-wa.yaml .
# make sure only your changes are there then run
helm upgrade utility-release --namespace utility  -f ../values-stg-au-wa-global.yaml -f values-stg-au-wa.yaml .

Once the vault pod is running, initialise the vault with following commands kubectl exec -it -n utility utility-release-vault-0 -- ash

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
Unseal Key 1: sFFsV4WrduLx9Q+eUp6AkWq3y4TDFGmzX4R32Nhlyus/ Unseal Key 2: GdYyubJ3dNvGQlGWmjeLmwZiHDmqig+qE3CLRaNOJWZ2 Unseal Key 3: fznNj7ENi43Q0Ne4QMD2UfkWEKVVuQZiL4KA97NOnEyl Unseal Key 4: KGqjY4hxzGK0iHO6Dd3nd79mhJK2YDXZc1A3natyv2vD Unseal Key 5: R1TFHO9OpOD00aPvMFqPpbv86KvmY9sFGWlsZxshd4nH

Initial Root Token: s.pXeidvipJ1Deo6rmZaum3yKJ

Refer: https://www.hashicorp.com/blog/announcing-the-vault-helm-chart

Okta OIDC setup

TEST_OG_ALCYON_VAULT_NEO 0oavnqe00fE0k96VJ0h7 DSDad4uYWK0kZfpBS7JmXj2ep5jgnrsbPgq-BDPu

path "secret/*" { capabilities = ["create", "read", "update", "delete", "list"] }

Migration Chart
cd migration-chart

kubectl create secret generic mongo-secret --from-literal=MONGO_PASSWORD='XXXX' -n migration
kubectl create secret generic migration-secret --from-literal=ORACLE_PASSWORD='XXXX' --from-literal=ALCYON_SERVICE_PASSWORD='XXXX' --from-literal=SIDEKIQ_USERNAME='XXXX' --from-literal=SIDEKIQ_PASSWORD='XXXX' -n migration

helm template -f ../values-stg-au-wa-global.yaml  -f values-stg-au-wa.yaml . -n migration-release --namespace migration > test.yaml

helm install --debug --dry-run -n migration-release --namespace migration -f ../values-stg-au-wa-global.yaml  -f values-stg-au-wa.yaml .

# To install
helm install migration-release --namespace migration -f ../values-stg-au-wa-global.yaml  -f values-stg-au-wa.yaml .

# To purge the release
helm uninstall -n migration migration-release

# To run upgrade.
helm diff upgrade migration-release --namespace migration -f ../values-stg-au-wa-global.yaml  -f values-stg-au-wa.yaml .
# make sure only your changes are there then run
helm upgrade migration-release --namespace migration -f ../values-stg-au-wa-global.yaml  -f values-stg-au-wa.yaml .

ARM Chart
cd arm-chart

kubectl create secret docker-registry regsecret --docker-server=docker.rtsprod.net  --docker-username=redflex --docker-password=XXX --docker-email=cst@redflex.com -n arm
kubectl create secret generic arm-secret --from-literal=DATASOURCE_PASSWORD='XXXX' -n arm

helm template  -f ../values-stg-au-wa-global.yaml -f values-stg-au-wa.yaml . -n arm-release --namespace arm > test.yaml

helm install --debug --dry-run -n arm-release --namespace arm  -f ../values-stg-au-wa-global.yaml -f values-stg-au-wa.yaml .

# To install
helm install arm-release --namespace arm  -f ../values-stg-au-wa-global.yaml -f values-stg-au-wa.yaml .

# To purge the release
helm uninstall -n arm arm-release

# To run upgrade.
helm diff upgrade arm-release --namespace arm  -f ../values-stg-au-wa-global.yaml -f values-stg-au-wa.yaml .
# make sure only your changes are there then run
helm upgrade arm-release --namespace arm  -f ../values-stg-au-wa-global.yaml -f values-stg-au-wa.yaml .

Stub Chart
cd /data/stub-chart

kubectl create secret docker-registry regsecret --docker-server=docker.rtsprod.net  --docker-username=redflex --docker-password=XXX --docker-email=cst@redflex.com -n stub

helm template  -f ../values-stg-au-wa-global.yaml -f values-stg-au-wa.yaml . -n stub-release --namespace stub > test.yaml

helm install --debug --dry-run -n stub-release --namespace stub  -f ../values-stg-au-wa-global.yaml -f values-stg-au-wa.yaml .

# To install
helm install stub-release --namespace stub  -f ../values-stg-au-wa-global.yaml -f values-stg-au-wa.yaml .

# To purge the release
helm uninstall -n stub stub-release

# To run upgrade.
helm diff upgrade stub-release --namespace stub  -f ../values-stg-au-wa-global.yaml -f values-stg-au-wa.yaml .
# make sure only your changes are there then run
helm upgrade stub-release --namespace stub  -f ../values-stg-au-wa-global.yaml -f values-stg-au-wa.yaml .