rem get public DNS by role in the cluster
set InstanceID=%1
curl -k -ssl3 "https://vdi.devfactory.com/jobs/undeployJobByInstanceID?instanceid=%InstanceID%&verify=vdiservice" > log.txt 2>>log.txt