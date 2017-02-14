#!/bin/bash
InstanceID=$1
RoleName=$2
IpType=$3
eval $RoleName=`curl -k -ssl3 "https://vdi.devfactory.com/clusters/rolemapping?instanceid=$InstanceID&role=$RoleName&verify=vdiservice&iptype=private" 2>>log.txt`
eval TempRoleName='$'$RoleName
echo $TempRoleName