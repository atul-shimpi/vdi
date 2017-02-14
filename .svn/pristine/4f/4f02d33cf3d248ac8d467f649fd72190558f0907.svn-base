rem get param from VDI server
set InstanceID=%1
set PARAM_NAME=%2
curl -k -ssl3 "https://vdi.devfactory.com/clusters/get_param?instanceid=%InstanceID%&param_name=%PARAM_NAME%&verify=vdiservice" > %PARAM_NAME%_FILE 2>>log.txt
for /f %%a in (%PARAM_NAME%_FILE) do set "%PARAM_NAME%=%%a"