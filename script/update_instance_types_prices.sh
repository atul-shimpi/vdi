#!/bin/sh

. ~/.bashrc
/usr/local/bin/ruby /var/www/gdevvdi/script/update_instance_types_prices.rb >> /etc/httpd/logs/update_instance_types_prices.log 2>&1
