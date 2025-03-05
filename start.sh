#!/usr/bin/env bash

export KEYDIR=/etc/shibboleth/certs
if [ ! -f "$KEYDIR/sp-cert.pem" ]; then
	shib-keygen -o $KEYDIR -n sp
fi

mkfifo -m 600 /tmp/logpipe-shib
chown _shibd:_shibd /tmp/logpipe-shib
unbuffer cat /tmp/logpipe-shib &
service shibd start
env APACHE_LOCK_DIR=/var/lock/apache2 APACHE_RUN_DIR=/var/run/apache2 APACHE_PID_FILE=/var/run/apache2/apache2.pid APACHE_RUN_USER=www-data APACHE_RUN_GROUP=www-data APACHE_LOG_DIR=/var/log/apache2  /docker-entrypoint.sh apache2 -DFOREGROUND


