#!/bin/sh
. ~/.bashrc
ruby /var/www/gdevvdi/script/stopLowCPUUsageInstances.rb >> /etc/httpd/logs/stopLowCPUUsageInstances.log 2>&1