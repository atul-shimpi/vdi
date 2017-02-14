#!/bin/bash
# Vdiclient init script.

# Let's put the logs of script execution in the same dir as this file.
LOG_FILE="$(dirname "$0")/vdiclient.log"

echo Checking out new sources for vdiclient... > $LOG_FILE
svn co https://subversion.devfactory.com/repos/webeeh/gdevVDI/trunk/external/vdiclient/shell --username vdiclient --password HqqRSNb5tKL9 --non-interactive >> $LOG_FILE 2>&1

echo Running vdiclient commands... >> $LOG_FILE
(
# Set curent dir as work directory
cd "$(dirname "$0")"

# Run vdiclient commands
chmod u+x ./shell/runvdiclient.sh
sh shell/runvdiclient.sh >> $LOG_FILE 2>&1
)
echo Vdiclient commands finished with return status: $? >> $LOG_FILE

