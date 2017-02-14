rem get the instanceid of the current vm
curl http://169.254.169.254/latest/meta-data/instance-id/ > instanceid.txt 2>>log.txt
for /f %%a in (instanceid.txt) do set "MYINSTANCEID=%%a"
echo %MYINSTANCEID%