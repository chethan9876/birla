# Selenium Grid Environment

Spinning up a new Selenium Grid environment is made easy by using Docker containers.

## Setting up EC2 instance

````bash
    terraform apply
````

## Overwriting selenium jar file in docker image
Currently the latest version of selenium-server-standalone.jar is 3.5.1 (http://selenium-release.storage.googleapis.com/3.5/selenium-server-standalone-3.5.1.jar). But the selenium grid docker image still uses 3.4.0 version. We need use the latest version of selenium-server-standalong.jar due to the issue (https://github.com/SeleniumHQ/selenium/issues/3808). The below line is to overwrite the selenium-server-standalong.jar in the docker image using the latest version.
````
- /home/core/selenium-server-standalone.jar:/opt/selenium/selenium-server-standalone.jar
````
