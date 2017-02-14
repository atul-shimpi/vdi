#!/bin/bash
InstanceID=$1
PARAM_NAME=$2
PARAM_VALUE=$3
curl -k -ssl3 "https://vdi.devfactory.com/clusters/set_param?instanceid=$InstanceID&param_name=$PARAM_NAME&param_value=$PARAM_VALUE&verify=vdiservice" 2>>log.txt