# Troubleshooting guide

## Docker container has no internet

````
pkill docker
iptables -t nat -F
ifconfig docker0 down
brctl delbr docker0
docker -d
````
It will force docker to recreate the bridge and reinit all the network rules

https://stackoverflow.com/questions/20430371/my-docker-container-has-no-internet

## Troubleshooting CoreOS

1. Cluster - Master not loading ETCD volumes and cluster fails to start.

    * Login to master instance with the IP address and notice "Failed Units"
    * Run the following commands to view the error.
    ````
    systemctl --failed
    journalctl -u coreos-cloudinit-779025201.service 
    journalctl -u kops-configuration.service
    ````
    
1. Cluster - Worker node not mounting EFS
    ````
    # Check existing mounts
    sudo mount | grep efs
    
    systemctl list-units  | grep efs
    #OUTPUT: run-r4ce7fbbeb23c4227951ba358ca78c53b.scope  loaded active running   Kubernetes transient mount for /var/lib/kubelet/pods/026920fa-f438-11e8-bf8d-0218ef249906/volumes/kubernetes.io~nfs/ingestr-efs
    
    journalctl -u run-r4ce7fbbeb23c4227951ba358ca78c53b.scope 
    #OUTPUT Dec 21 14:25:00 ip-10-50-3-158.ap-southeast-2.compute.internal systemd[1]: Started Kubernetes transient mount for r/lib/kubelet/pods/026920fa-f438-11e8-bf8d-0218ef249906/volumes/kubernetes.io~nfs/ingestr-efs
    
    systemctl status run-r4ce7fbbeb23c4227951ba358ca78c53b.scope
    #● run-r4ce7fbbeb23c4227951ba358ca78c53b.scope - Kubernetes transient mount for /var/lib/kubelet/pods/026920fa-f438->
    #   Loaded: loaded (/run/systemd/transient/run-r4ce7fbbeb23c4227951ba358ca78c53b.scope; transient)
    #Transient: yes
    #   Active: active (running) since Fri 2018-12-21 14:25:00 UTC; 2 days ago
    #    Tasks: 2 (limit: 32767)
    #   Memory: 772.0K
    #   CGroup: /system.slice/run-r4ce7fbbeb23c4227951ba358ca78c53b.scope
    #           ├─1609 /usr/bin/mount -t nfs ingestr-efs.nemo.redflexrms.onl:/ /var/lib/kubelet/pods/026920fa-f438-11e8->
    #           └─1626 /sbin/mount.nfs ingestr-efs.nemo.redflexrms.onl:/ /var/lib/kubelet/pods/026920fa-f438-11e8-bf8d-0>

    # Lot of running mount tasks
    ps -ef | grep mount
    
    journalctl -u kops-configuration.service
    ````

## Calico node failure due to old DHCP domain-name

To view logs:
````
kubectl get pods -n kube-system
kubectl logs -n kube-system calico-node-kfxnm calico-node
kubectl logs -n kube-system calico-node-kfxnm calico-node -p #If pod had crashed already.
````

Install calicoctl as container
````
 kubectl apply -f https://docs.projectcalico.org/v3.0/getting-started/kubernetes/installation/hosted/kubernetes-datastore/calicoctl.yaml
````

### View etcd endpoint
SSH into the master node. 
`docker inspect <container_id> | grep etcd`

View Data: `curl http://etcd-a.internal.atlas.rts.onl:4001/v2/keys/calico/v1`
Delete Data from etcd: `curl http://etcd-a.internal.atlas.rts.onl:4001/v2/keys/calico?recursive=true -XDELETE`

## Redhat CIS Image

## Troubleshooting Notes

1. SSH agent forwarding - multiple instances

Pass the flag -A:

`ssh -A ec2-user@10.202.1.80`

2. Check failed service

````
sudo systemctl --failed
sudo journalctl -u cloud-final.service -f

# /var/lib/cloud/instance/scripts/part-001: line 53: unexpected token `(', conditional binary operator
````
3. Check supported file systems `cat /proc/filesystems`
4. To install container-selinux enable the RHEL extras repo first:
````bash 
yum-config-manager --enable rhel-7-server-rhui-extras-rpms
yum -y install container-selinux
yum-config-manager --disable rhel-7-server-rhui-extras-rpms
````
 vi /etc/yum.repos.d/redhat-rhui.repo - enable extras repo.
Ref: https://aws.amazon.com/partners/redhat/faqs/

5. Overlay filesystem - Set Docker filesystem to overlay
`vi /etc/sysconfig/docker-storage` and add  DOCKER_STORAGE_OPTIONS="--storage-driver overlay "

6. Test the cluster

docker run -it --rm -p 80:80 -v ~/.aws:/root/.aws -v ~/.ssh:/root/.ssh -v ~/projects/redflex-infrastructure/alcyon/alcyon_server:/data dockerp.rtsprod.net/common/kubernetes-tools:1.12.0-beta.1

7. API server not running
systemctl cat kubelet

8. Follow logs - `journalctl -xef -n 30`

9.  View user data
````
curl http://169.254.169.254/latest/user-data/
````

10. If there is a conflict in Kubernetes version and Kubelet version, nodes will be in NotReady state. To fix it, uninstall kubelet and install correct version
````
yum remove -y kubelet
yum -y install kubeadm-1.16.4 kubelet-1.16.4
kubeadm upgrade node
````

11. View Kubelet logs
````
journalctl -xef -n 30 -u kubelet
````

12. Windows Active directory ports for Security group:

https://support.microsoft.com/en-us/help/179442/how-to-configure-a-firewall-for-domains-and-trusts

||Server Port||Service||
|135/TCP|RPC Endpoint Mapper|
|1024-65535/TCP|RPC for LSA, SAM, Netlogon (*)|
|389/TCP/UDP|LDAP|
|636/TCP|LDAP SSL|
|3268/TCP|LDAP GC|
|3269/TCP|LDAP GC SSL|
|53/TCP/UDP|DNS|
|88/TCP/UDP|Kerberos|
|445/TCP|SMB|
|1024-65535/TCP|FRS RPC (*)|

13. To Join Kubeadm node after the certificate expiry, do the following:

````sh
# Go to master 1 /root dir and run the following command:
kubeadm --config kubeadm-config.yaml init phase upload-certs --upload-certs

#[upload-certs] Using certificate key:
#20be9ab531fb47479f7ca9ee2c8a9ce892ff2186f6a5ffac4edb951cd942d06b

#Generate new token as well
kubeadm token create
#icwiqj.z855f3pf3o1xjeif
````

Replace the token and certificate key in the kubeadm-join.sh script.  eg.,

````
cd /root
for i in {1..10}; do \
    KUBEADM_TOKEN=nezgnb.1enrjka8jyxafdxu && \
    KUBEADM_CA_CERT=$(aws --region us-gov-west-1 ssm get-parameter --name /kubadm/cluster/ca-cert --with-decryption | jq -r .Parameter.Value) && \
    KUBEADM_CERTIFICATE_KEY=50563c6f95a635fb929d88caf2f99f46b3cce0fa205dd67beae068e42fef2ac2 && \
    kubeadm join api.canyon.redflexusa.onl:443 --token $KUBEADM_TOKEN  --discovery-token-ca-cert-hash $KUBEADM_CA_CERT --control-plane --certificate-key $KUBEADM_CERTIFICATE_KEY -v10 && \
    break || sleep 15; done
````

14. Docker container has no Internet connection. UnknownHostException:


15. /dev/nvme1n1 is not mounted.

If the initial Ignition config was wrong, changing the user data does not recreate the unit file.
Goto, `/etc/systemd/system/` and edit the specific mount file to correct value.
eg., `sudo vi /etc/systemd/system/data.mount`

Then enable the mount by running `sudo systemctl enable data.mount`

16. Debug failed startup service

````
sudo systemctl --failed

#  UNIT                LOAD   ACTIVE SUB    DESCRIPTION
#<E2><97><8F> cloud-final.service loaded failed failed Execute cloud user/final scripts

journalctl -u cloud-final.service 
````
17. To view the user-data file in Redhat linux instance:
`sudo cat /var/lib/cloud/instance/scripts/part-001`

18. K8s Cluster master not able to join with certificate missing error.
 
Run the following command on master 1 to upload the certificates again. Update the certificate key in kubeadm-join script.
````
 kubeadm init  --config /root/kubeadm-config.yaml phase upload-certs --upload-certs
````
19. List all the ports that are currently listening

`netstat -tulpn | grep LISTEN`

20. Debug nodeport issue:

`netstat -tulpn | grep proxy` 
`tcpdump port 30233`
for i in {1..15}; do curl 10.35.3.76:32000 && sleep 2; done

21. Change Docker networking IP range:

Create new daemon.json file `/etc/docker/daemon.json`
````json
{
  "default-address-pools" : [
    {
      "base" : "10.255.0.0/16",
      "size" : 24
    }
  ]
}
````

restart docker `systemctl restart docker`

To verify
`ifconfig docker0 | grep -Po '(?<=inet )[\d.]+'`


22. Ran out of disk space

````
df -h
sudo du -a /home/bamboo | sort -n -r | head -n 5
````

23. Linux AD integration issues

````
#Login failure logs
tail -200f /var/log/secure

#pam_sss(su-l:auth): received for user dnunez@usgovcloud.redflex.com: 17 (Failure setting user credentials)

````
