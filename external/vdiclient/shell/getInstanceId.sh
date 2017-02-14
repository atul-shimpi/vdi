#!/bin/bash
MYINSTANCEID=`curl "http://169.254.169.254/latest/meta-data/instance-id/" 2>>log.txt`
echo $MYINSTANCEID