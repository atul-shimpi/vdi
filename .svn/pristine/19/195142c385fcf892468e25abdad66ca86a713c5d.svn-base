rem set a param to VDI server that other instances in the cluster can get that
set InstanceID=%1
set PARAM_NAME=%2
set PARAM_VALUE=%3
curl -k -ssl3 "https://vdi.devfactory.com/clusters/set_param?instanceid=%InstanceID%&param_name=%PARAM_NAME%&param_value=%PARAM_VALUE%&verify=vdiservice" 2>>log.txt