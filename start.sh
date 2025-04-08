#!/usr/bin/env bash

export KEYDIR=/etc/shibboleth/certs
if [ ! -f "$KEYDIR/sp-cert.pem" ]; then
    shib-keygen -o $KEYDIR -n sp
fi

mkfifo -m 600 /tmp/logpipe-shib
chown _shibd:_shibd /tmp/logpipe-shib
unbuffer cat /tmp/logpipe-shib &
service shibd start
echo -e "ServerName https://$(hostname -f):443\nUseCanonicalName On\n" >> /etc/apache2/apache2.conf

# same command that is run in /docker-entrypoint.sh to sync roundcube dir
# doing it beforehand to not overwrite the compser.lock file and other things
tar cf - --one-file-system -C /usr/src/roundcubemail . | tar xf -

lessc --rewrite-urls=all plugins/libkolab/skins/elastic/libkolab.less > plugins/libkolab/skins/elastic/libkolab.min.css
composer require --no-interaction \
    pear/http_request2 \
    caxy/php-htmldiff \
    lolli42/finediff \
    sabre/vobject

env APACHE_LOCK_DIR=/var/lock/apache2 APACHE_RUN_DIR=/var/run/apache2 APACHE_PID_FILE=/var/run/apache2/apache2.pid APACHE_RUN_USER=www-data APACHE_RUN_GROUP=www-data APACHE_LOG_DIR=/var/log/apache2 /docker-entrypoint.sh apache2 -DFOREGROUND
