#!/bin/bash
#get userdate as a bat
curl http://169.254.169.254/latest/user-data > vdiuserdata.sh
# change the file format
dos2unix vdiuserdata.sh
echo "Will run the following user commands:"
echo -e "====================================="
cat vdiuserdata.sh
echo -e "\n====================================="
# run the user script asynchorously not to block this script
sh vdiuserdata.sh &
