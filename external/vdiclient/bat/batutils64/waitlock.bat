set InstanceID=%1
set LockName=%2
:WAITLOOP
curl -k -ssl3 "https://vdi.devfactory.com/clusters/checklock?instanceid=%InstanceID%&lockname=%LockName%&verify=vdiservice" > waitedlockstatus.txt 2>>log.txt
for /f %%a in (waitedlockstatus.txt) do (
    echo "%%a"
    if "%%a" EQU "unlock" (
       goto UNLOCKED
    )
    sleep 30
    goto WAITLOOP
)
:UNLOCKED