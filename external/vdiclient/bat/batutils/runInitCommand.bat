rem get public DNS by role in the cluster
set InstanceID=%1
set InitialCommandFile=initialcommand.bat
curl -k -ssl3 "https://vdi.devfactory.com/jobs/initialcommand?instanceid=%InstanceID%&verify=vdiservice" > %InitialCommandFile% 2>>log.txt
call initialcommand.bat