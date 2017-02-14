#!/bin/bash
InstaceID=$1
LockName=$2
curl -k -ssl3 "https://vdi.devfactory.com/clusters/updatelock?instanceid=$InstaceID&lockname=$LockName&verify=vdiservice" 2>>log.txt