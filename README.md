# Alcyon Helm charts

## Initialize

````sh
helm init
helm init --upgrade # To upgrade Tiller on the server
helm repo add incubator https://kubernetes-charts-incubator.storage.googleapis.com/
helm create alcyon-chart
````

## Prerequisite

1. Setup Kubernetes cluster
2. Create the namespace if needed
3. Run the docker container to get access to kubectl

    ````
    $AWS_ACCESS_KEY_ID = aws --profile default configure get aws_access_key_id
    $AWS_SECRET_ACCESS_KEY= aws --profile default configure get aws_secret_access_key
    
    # For Atlas cluster
    docker run -it --rm -v /home/core/helm:/data -e NAME=atlas.rts.onl -e KOPS_STATE_STORE=s3://alcyon-k8s-bucket -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY docker.rtsprod.net/common/kubernetes-tools:latest
    ````
    
    In the container
    ````
    kops export kubecfg $NAME
    ````
4. Setup default bootstrap cluster roles and bindings. Refer [here](https://stackoverflow.com/questions/41309420/how-to-create-users-groups-restricted-to-namespace-in-kubernetes-using-rbac-api)
NOTE: This is still referring to Version 1.8 cluster.
 
    ````
    kubectl create -f https://raw.githubusercontent.com/kubernetes/kubernetes/release-1.8/plugin/pkg/auth/authorizer/rbac/bootstrappolicy/testdata/cluster-roles.yaml
    kubectl create -f https://raw.githubusercontent.com/kubernetes/kubernetes/release-1.8/plugin/pkg/auth/authorizer/rbac/bootstrappolicy/testdata/cluster-role-bindings.yaml --validate=false
    ````
    To verify the new roles:
    ````
    kubectl get clusterroles,clusterrolebindings
    ````

5. Setup Tiller service account with correct access for HELM and install tiller
    ````
    kubectl create -f helm-rbac-config.yaml
    helm init --service-account tiller --upgrade
    ````

6. Setup the image pull secret
    ````
    kubectl create secret docker-registry regsecret --docker-server=docker.rtsprod.net --docker-username=<username> --docker-password=<password> --docker-email=venkatesh.nannan@redflex.com.au -n <namespace> 
    ```` 

## Prerequisite - locally

### Change Line ending

    Click on root folder redflex-helm-chart
    then from menu select File -> File Properties -> Line Separators -> LF - Unix and MacOS (\n)

## Deploy

## Common commands

````
helm lint # Verify script is fine
helm ls
````

## Commands

Environment specific commands are listed in the individual README files.
 
## Other commands

To delete all stuck Cron jobs
````
echo "Deleting all jobs (in parallel - it can trash CPU)"

kubectl get jobs --all-namespaces | sed '1d' | awk '{ print $2, "--namespace", $1 }' | while read line; do
  echo "Running with: ${line}"
  kubectl delete jobs ${line} &
  sleep 0.05
done
````

To update dependency
````
helm dependency update
````

## Troubeshooting

Sample commands that will help 
````
 kubectl get pods -o wide -n kube-system
 kubectl get configmap base-release-nginx-ingress-controller -n kube-system -o yaml
 kubectl logs -f --tail=300 base-release-nginx-ingress-controller-7b474cf497-f9pgw -n kube-system
 kubectl describe svc base-release-nginx-ingress-controller -o yaml -n kube-system
 kubectl get svc base-release-nginx-ingress-controller -o jsonpath="{.status}" -n kube-system
````

To debug cloud manager (eg., ELB not created)
````
 #Find the kube-controller-manager pods names
 kubectl get pods -n kube-system | grep manager
 #look at logs in each one
 kubectl logs -f --tail=300 kube-controller-manager-ip-10-33-6-60.ap-southeast-2.compute.internal -n
  kube-system
````

To run Cron Job now:
````
kubectl create job test-inbox-cleanup --from=cronjob/ingestr-cleanup-inbox-emptydir -n test
````
You can do 'get pods' and view the logs of that pod to view any error message.

To debug Nginx ingress configs copy the nginx.conf file from the nginx-ingress-controller to local and view it:

````
kubectl cp -n kube-system base-release-nginx-ingress-controller-84b6bff7b8-w9d2k:/etc/nginx/nginx.conf nginx.conf
````

No ELB is created for ingress-controller

````
kubectl cluster-info dump | grep LoadBalancer
kubectl get events -n kube-system
````

## Setup to deploy helm charts to an EKS cluster from your local machine

1. Login to docker using the following command
```shell
docker login docker.rtsprod.net --username redflex
```
1. Setup AWS credentials and then authenticate using Okta by following the "Okta login for NEW Redflex.com users" 
   section in the README file from [redflex-infrastructure](http://bitbucket.rtsprod.net/projects/DEV/repos/redflex-infrastructure/browse) repository
1. Update kubeconfig and change the current-context using the following command
```shell
aws eks --region <region> update-kubeconfig --name <cluster-name>
```
1. Run the following commands
```shell
docker run --rm -v $HOME/.aws:/root/.aws:ro -v $HOME/.kube/config:/root/.kube/config -v <redflex-helm-charts folder path>:/usr/share/redflex -it docker.rtsprod.net/common/kubernetes-tools:latest
cd /usr/share/redflex
```

## S3 cidr block
To find S3 cidr block  

``` Go to AWS console >> VPC >> Managed Prefix Lists >> find S3 prefix list >> Add Prefix list entries ```

Add those entries to S3 cidr block in network policy

## Issues

1. "bad character U+002D '-'" : HELM chart does not allow you to access values which has "-" in it. https://github.com/helm/helm/pull/4379
    Workaround: Use index eg., {{ index .Values "fluentd-elasticsearch" "elasticsearch" "cidr" }}
    

## Reference
https://docs.helm.sh/using_helm/
https://docs.helm.sh/chart_template_guide/#getting-started-with-a-chart-template
https://github.com/kubernetes/helm/blob/master/docs/charts.md#tags-and-condition-fields-in-requirementsyaml
https://github.com/kubernetes/helm/blob/master/docs/charts.md
