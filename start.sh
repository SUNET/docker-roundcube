#!/usr/bin/env bash

echo -e "ServerName https://$(hostname -f):443\nUseCanonicalName On\n" >> /etc/apache2/apache2.conf
cd /var/www/html && lessc --relative-urls -x plugins/libkolab/skins/elastic/libkolab.less > plugins/libkolab/skins/elastic/libkolab.min.css
env APACHE_LOCK_DIR=/var/lock/apache2 APACHE_RUN_DIR=/var/run/apache2 APACHE_PID_FILE=/var/run/apache2/apache2.pid APACHE_RUN_USER=www-data APACHE_RUN_GROUP=www-data APACHE_LOG_DIR=/var/log/apache2  /docker-entrypoint.sh apache2 -DFOREGROUND


