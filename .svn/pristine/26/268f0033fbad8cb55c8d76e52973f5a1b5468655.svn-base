#!/bin/bash
InstanceID=$1
PARAM_NAME=$2
eval $PARAM_NAME=`curl -k -ssl3 "https://vdi.devfactory.com/clusters/get_param?instanceid=%InstanceID%&param_name=%PARAM_NAME%&verify=vdiservice" 2>>log.txt`
eval TempPARAM_NAME='$'$PARAM_NAME
echo $TempPARAM_NAME