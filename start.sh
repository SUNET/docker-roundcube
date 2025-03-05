#!/usr/bin/env bash

export KEYDIR=/etc/shibboleth/certs
if [ ! -f "$KEYDIR/sp-cert.pem" ]; then
	shib-keygen -o $KEYDIR -n sp
fi

mkfifo -m 600 /tmp/logpipe-shib
chown _shibd:_shibd /tmp/logpipe-shib
unbuffer cat /tmp/logpipe-shib &
service shibd start
/docker-entrypoint.sh "${@}"


