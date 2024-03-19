# Nexus Docker image

## Accessing Nexus



## Installation 

* Run the following command to setup the Nexus environment.
````
    terraform apply
````

Nexus will be available at https://nexus.rtsprod.net

### Login details:
* Admin User - *admin/RedflexAdmin* (Default Nexus admin user: admin/admin123)
* User - *redflex/redflex*


## Post Installation

Add following docker repositories once Nexus is running
* docker-hub - proxy to Docker Hub.
* docker-hosted - private docker registry. Set http port 17444 for the registry.
* docker-all - group docker registry for both docker-hub and docker-hosted. Set http port 17443 for the registry.
* Rubygems - proxy to Rubygems site

## Accessing the Nexus Repository

### Docker

#### Pull Docker images

````
    docker login -u redflex -p redflex docker.rtsprod.net
    docker pull docker.rtsprod.net/redflex/rbo-oracle-xe
````

#### Publishing Docker images to Nexus

Port 18443 has to be exposed for Docker hosted repository.

````
    docker login -u redflex -p redflex docker.rtsprod.net
    docker tag rbo-oracle-xe docker.rtsprod.net/rbo-oracle-xe
    docker push docker.rtsprod.net/rbo-oracle-xe
````

### RubyGems

In Gemfile add the source as following:

````
source 'https://redflex:redflex@nexus.rtsprod.net/repository/Rubygems/'

````

NOTE: If you are facing SSL issues, follow the steps mentioned in [Ruby Dev Env]( https://redflex.atlassian.net/wiki/display/PHX/Setup+Ruby+development+environment)

### Maven Repository

#### Trust Let's Encrypt root certificate

Let's encrypt root certificate is not trusted by JAVA by default. Download the [chain.pem](chain.pem) file from this repo folder.
Add the root certificate to JDK by running the following command once.

````
    %JAVA_HOME%\bin\keytool -trustcacerts -keystore %JAVA_HOME%/jre/lib/security/cacerts -storepass changeit -noprompt -importcert -file chain.pem
````

eg.,
keytool.exe -trustcacerts -keystore c:/PROGRA~1/Java/jdk1.6.0_45/jre/lib/security/cacerts -storepass changeit -noprompt -importcert -file chain.pem


#### Gradle

````
    repositories {
        maven {
            credentials {
                username 'redflex'
                password 'redflex'
            }
            url 'http://nexus.rtsprod.net/repository/maven-public/'
        }
    }

````

#### Maven

```` Settings xml
<settings>
	<servers>
		<server>
			<id>nexus</id>
			<username>redflex</username>
			<password>redflex</password>
		</server>
	</servers>

	<mirrors>
		<mirror>
			<id>nexus</id>
			<mirrorOf>*</mirrorOf>
			<url>http://nexus.rtsprod.net/repository/maven-public/</url>
		</mirror>
	</mirrors>
	<profiles>
		<profile>
			<id>nexus</id>
			<!--Enable snapshots for the built in central repo to direct -->
			<!--all requests to nexus via the mirror -->
			<repositories>
				<repository>
					<id>central</id>
					<url>http://central</url>
					<releases>
						<enabled>true</enabled>
					</releases>
					<snapshots>
						<enabled>true</enabled>
					</snapshots>
				</repository>
			</repositories>
			<pluginRepositories>
				<pluginRepository>
					<id>central</id>
					<url>http://central</url>
					<releases>
						<enabled>true</enabled>
					</releases>
					<snapshots>
						<enabled>true</enabled>
					</snapshots>
				</pluginRepository>
			</pluginRepositories>
		</profile>
	</profiles>
	<activeProfiles>
		<activeProfile>nexus</activeProfile>
	</activeProfiles>
</settings>
````  
