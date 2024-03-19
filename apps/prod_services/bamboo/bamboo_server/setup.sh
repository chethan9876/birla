#!/bin/bash

#Switch to root user
sudo su -
apt update
apt upgrade

#Add user
useradd -p safTXXv9ll2Ao -d /home/bamboo -g ubuntu -m bamboo

# Svn
apt-get install -y subversion zip

# bamboo
mkdir /opt/atlassian
wget -O /opt/atlassian/bamboo.tar.gz https://www.atlassian.com/software/bamboo/downloads/binary/atlassian-bamboo-6.1.0.tar.gz
cd /opt/atlassian
tar -xvzf bamboo.tar.gz #should extract bamboo to /opt/atlassian/atlassian-bamboo-6.1.0
ln -s atlassian-bamboo-6.1.0/ bamboo
#mv atlassian* bamboo

echo "bamboo.home=/home/bamboo" >> /opt/atlassian/bamboo/atlassian-bamboo/WEB-INF/classes/bamboo-init.properties
mv /home/ubuntu/bamboo.cfg.xml /home/bamboo/bamboo.cfg.xml

# Install JDK
echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections
add-apt-repository -y ppa:webupd8team/java
apt update
apt install -y oracle-java8-installer oracle-java8-set-default

# Install JDK 6 to /usr/lib/jvm/jdk1.6.0_45
# File must exist @ /home/ubuntu/jdk-6u45-linux-x64.bin
chmod +x /home/ubuntu/jdk-6u45-linux-x64.bin
cd /usr/lib/jvm/
sudo /home/ubuntu/jdk-6u45-linux-x64.bin

# Install Chrome
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
sh -c 'echo "deb https://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list'
apt-get update
apt-get -y install xvfb google-chrome-stable

# Install Docker
apt install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository -y "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt update
apt install -y docker-ce docker-compose
systemctl enable docker

# Install Ant
wget http://archive.apache.org/dist/ant/binaries/apache-ant-1.9.6-bin.tar.gz
tar -xf apache-ant-1.9.6-bin.tar.gz  -C /usr/local
ln -s /usr/local/apache-ant-1.9.6/ /usr/local/ant
rm -f apache-ant-1.9.6-bin.tar.gz

# Install Maven
apt-get install maven
mv /usr/share/maven/conf/settings.xml /usr/share/maven/conf/settings.xml.default
mv /home/ubuntu/settings.xml /usr/share/maven/conf/settings.xml

# Install kubectl, kops
sudo apt -y install snap awscli
sudo snap install kubectl --classic
sudo snap install kops

# Install AddressIT Wrapper
apt-get install unzip
cd /home/ubuntu/
unzip AddressIT_Wrapper.zip
mv /home/ubuntu/AddressIT_Wrapper /home/bamboo/AddressIT_Wrapper
chown bamboo:ubuntu -R /home/bamboo/AddressIT_Wrapper

# Install RVM
sudo apt-get -y install software-properties-common

# Add capability to run Docker
usermod -aG docker bamboo
usermod -aG docker ubuntu
usermod -aG root jenkins

chown bamboo:ubuntu -R /opt/atlassian/bamboo
chown bamboo:ubuntu -R /home/bamboo

# IP Forwarding port 80 to 8080
sudo sysctl -w net.ipv4.ip_forward=1
sudo /etc/init.d/procps restart

iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 8085
#iptables -t nat -A OUTPUT -o lo -p tcp --dport 80 -j REDIRECT --to-port 8085
sh -c "iptables-save > /etc/iptables.rules"
apt install -y iptables-persistent
echo "#!/bin/sh" >> /etc/network/if-pre-up.d/iptablesload
echo "iptables-restore < /etc/iptables.rules" >> /etc/network/if-pre-up.d/iptablesload
echo "exit 0" >> /etc/network/if-pre-up.d/iptablesload

#To list Port forwarding
# iptables -t nat -L

#To Delete port forwarding
# iptables -t nat -D PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 8085
# iptables -tex nat -D OUTPUT -o lo -p tcp --dport 80 -j REDIRECT --to-port 8085

# Set timezone
ln -sf /usr/share/zoneinfo/Australia/Melbourne /etc/localtime
echo "ZONE=\"Australia/Melbourne\"" >> /etc/sysconfig/clock
echo "UTC=false" >> /etc/sysconfig/clock

# Install GDM for Xhost
apt install -y gdm

#exit # Switch back to Ubuntu user

sudo su - bamboo

#Install NVM and NPM latest
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.4/install.sh | bash
source .bashrc
nvm install 4.2.6
nvm install 6.11.2
# For bamboo jobs still referring to npm.cmd..
ln -s /home/bamboo/.nvm/versions/node/v4.2.6/bin/npm /home/bamboo/.nvm/versions/node/v4.2.6/bin/npm.cmd

#Install RVM
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
cd /tmp
curl -sSL https://get.rvm.io -o rvm.sh
cat /tmp/rvm.sh | bash -s stable --rails
source /home/bamboo/.rvm/scripts/rvm
rvm install 2.4.1
rvm gemset create default
rvm use 2.4.1@default
gem install bundler

echo "source /home/bamboo/.rvm/scripts/rvm" >> /home/bamboo/.bashrc
echo "rvm use 2.4.1@default" >> /home/bamboo/.bashrc
echo "export ANT_HOME=/usr/local/ant" >> /home/bamboo/.bashrc
echo "rvm_silence_path_mismatch_check_flag=1" >> /home/bamboo/.rvmrc
echo -e "export PATH=\$PATH:/usr/local/ant/bin" >> /home/bamboo/.bashrc
echo "xhost +" >> /home/bamboo/.bashrc
source .bashrc
# Once bamboo.sh file is copied to /etc/init.d, you can start the service as sudo /etc/init.d/bamboo.sh start. until then
/opt/atlassian/bamboo/bin/start-bamboo.sh -fg