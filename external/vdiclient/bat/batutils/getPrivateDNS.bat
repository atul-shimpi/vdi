rem get public DNS by role in the cluster
set InstanceID=%1
set RoleName=%2
set PrivateDNSTempFile=privatednstemp.txt
curl -k -ssl3 "https://vdi.devfactory.com/clusters/rolemapping?instanceid=%InstanceID%&role=%RoleName%&verify=vdiservice&iptype=private" > %PrivateDNSTempFile% 2>>log.txt
for /f %%a in (%PrivateDNSTempFile%) do set "%RoleName%=%%a"