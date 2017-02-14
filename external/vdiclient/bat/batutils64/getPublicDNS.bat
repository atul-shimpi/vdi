rem get public DNS by role in the cluster
set InstanceID=%1
set RoleName=%2
set IpType=%3
set PublicDNSTempFile=publicdnstemp.txt
curl -k -ssl3 "https://vdi.devfactory.com/clusters/rolemapping?instanceid=%InstanceID%&role=%RoleName%&verify=vdiservice&iptype=%IpType%" > %PublicDNSTempFile% 2>>log.txt
for /f %%a in (%PublicDNSTempFile%) do set "%RoleName%=%%a"