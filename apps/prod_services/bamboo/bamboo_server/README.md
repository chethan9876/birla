# Bamboo

## IAM Access control

Bamboo server needs access to Kubernetes S3 state bucket from the Dev account to rollout latest images to the K8s cluster.

## Manual Configuration

1. Enable password login 
````
sudo su - 
vi /etc/ssh/sshd_config
# Set "PasswordAuthentication yes"
````

2. Manually copy the following files to /home/ubuntu
````
\\cabernet2\Shared\Software\jdk-6u45-linux-x64.bin
\\cabernet2\Shared\Software\export_atlassianbamboo_51020_20170713.zip
\\cabernet2\Shared\Software\AddressIT_Wrapper.zip
<Proj>/resources/settings.xml to /home/ubuntu/settings.xml
````
Extract AddressIT_Wrapper.zip by running 
````
unzip AddressIT_Wrapper.zip 
````

3. Change Bamboo timezone
````
sudo vi /opt/atlassian/bamboo/bin/setenv.sh

# set JVM_SUPPORT_RECOMMENDED_ARGS="-Duser.timezone=Australia/Melbourne"
````

5. Run setup.sh

## Details

### Credentials

Admin User: bambooadmin/
SSH Details: bamboo/

### Locations
````
Bamboo Home:  /opt/atlassian/bamboo/
Bamboo Data:  /home/bamboo
Bamboo Logs:  /home/bamboo/logs
````

### Enabling HTTPS on bamboo server

Enter the password as redflex while generating the certificate 

````
$JAVA_HOME/bin/keytool -genkey -alias tomcat -keyalg RSA
````


### Restart Bamboo
````
sudo /etc/init.d/bamboo.sh restart
sudo iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 8085
sudo iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 8085 DROP
````

### Customisation
* Increase max mem size to 2048m in *<BAMBOO_HOME>/bin/setenv.sh*
* Allow node command to be accessible from `sh` shell
https://stackoverflow.com/questions/18130164/nodejs-vs-node-on-ubuntu-12-04
````
sudo ln -s /usr/bin/nodejs /usr/local/bin/node
````

## Upgrading Bamboo

Login as ubuntu user to stop bamboo server.

````
#Stop
sudo /etc/init.d/bamboo.sh stop
````

Login as bamboo user

````
cd /opt/atlassian/
wget https://www.atlassian.com/software/bamboo/downloads/binary/atlassian-bamboo-6.7.2.tar.gz
tar -xvzf atlassian-bamboo-6.7.2.tar.gz
rm -f bamboo
ln -s atlassian-bamboo-6.6.1/ bamboo
echo "bamboo.home=/home/bamboo" >> /opt/atlassian/bamboo/atlassian-bamboo/WEB-INF/classes/bamboo-init.properties
````

Login as ubuntu user to start bamboo server.

````
#Start after a min as stop takes some time.
sudo /etc/init.d/bamboo.sh start
````

If there is any issues with index folder, rename `/home/bamboo/index` to `/home/bamboo/index_old`

## Reference
* Run docker as non-root user https://docs.docker.com/engine/installation/linux/linux-postinstall/
* http://o7planning.org/en/11363/redirecting-port-80-443-on-ubuntu-server-using-iptables
* https://confluence.atlassian.com/bamboo/running-bamboo-as-a-linux-service-416056046.html
* https://askubuntu.com/questions/311053/how-to-make-ip-forwarding-permanent
* https://help.ubuntu.com/community/IptablesHowTo#Configuration_on_Startup_for_NetworkManager
* https://confluence.atlassian.com/bamkb/how-to-force-the-timezone-of-bamboo-server-913378951.html