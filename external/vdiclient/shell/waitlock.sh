#!/bin/bash
InstanceID=$1
LockName=$2
waitedlockstatus=`curl -k -ssl3 "https://vdi.devfactory.com/clusters/checklock?instanceid=$InstanceID&lockname=$LockName&verify=vdiservice" 2>>log.txt`
while [ "$waitedlockstatus" != "unlock" ]
do
   sleep 30
   waitedlockstatus=`curl -k -ssl3 "https://vdi.devfactory.com/clusters/checklock?instanceid=$InstanceID&lockname=$LockName&verify=vdiservice" 2>>log.txt`
done