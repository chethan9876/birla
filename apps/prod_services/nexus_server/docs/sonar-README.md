# Sonar Docker image

## Accessing Sonar

Nexus will be available at https://sonar.rts.onl

* Login details:
    1. Admin User - Default admin/admin but the password has been changed to *admin/RedflexAdmin*
    

## Database

Sonarqube uses Postgres DB server to persist all information.


````
#Dump db from sonardb
pg_dump -Fc -U sonar sonar > /data/sonardb_18082020.dump


#Run docker container
docker run -it -v  /data/sonardb/backup:/data --entrypoint ash  --rm jbergknoff/postgresql-client
pg_restore -U postgres -h sonardb.cvpjar0twgf3.ap-southeast-2.rds.amazonaws.com -d sonar -e --password  /data/sonardb_18082020.dump

GRANT ALL PRIVILEGES ON SCHEMA public TO sonar;
````
