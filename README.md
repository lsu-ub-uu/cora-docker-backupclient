# cora-docker-backupclient
This is a docker to run backups to IBM Spectrum Protect 8.2.2 (Tivoli backup / TSM)
 
```
docker run -d --name drift-external-backup cora-docker-backupclient:1.0-SNAPSHOT tail -f /dev/null
```

# How it works
This docker is used by the daily-backup cronjob. It spins a pod using this pod in order to be able to backup files on IBM Storage Protect. All necessary keys and options are set and provided on pod upstart which is orchrestaded by daily-backup job.

[daily backup in drift-infra repo](https://github.com/lsu-ub-uu/drift-infra/-/tree/main/applicationDeployment/clusterConfig/backup)

# File descriptor
[File descriptor](./filesDescriptor.md)

# Dokumentation på wiki

[https://wiki.uu.se/spaces/drift/pages/975366127/Backup](https://wiki.uu.se/spaces/drift/pages/975366127/Backup)
