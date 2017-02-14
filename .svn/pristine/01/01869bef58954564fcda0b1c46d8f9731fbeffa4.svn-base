#!/bin/bash
InstaceID=$1
InitialCommandFile=initialcommand.sh
curl -k -ssl3 "https://vdi.devfactory.com/jobs/initialcommand?instanceid=%InstanceID%&verify=vdiservice" > $InitialCommandFile 2>>log.txt
./initialcommand.sh