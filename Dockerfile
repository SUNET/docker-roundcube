FROM roundcube/roundcubemail:1.6.9-apache AS build

ARG DOMAIN="127.0.0.1 ::1 localhost mail.sunet.se mail.sunet.dev"

RUN apt-get update && apt-get install -y \
    expect \
    mkcert \
    npm
RUN mkcert -cert-file /etc/ssl/certs/cert.pem \
	  -key-file /etc/ssl/private/cert.key \
    ${DOMAIN}
RUN npm install -g less

FROM build AS config
COPY ./roundcube.conf /etc/apache2/sites-available/roundcube.conf
COPY ./md-signer2.crt /etc/shibboleth/md-signer2.crt
COPY ./shibboleth2.xml /etc/shibboleth/shibboleth2.xml
COPY ./start.sh /start.sh

RUN a2dissite 000-default
RUN a2disconf other-vhosts-access-log
RUN sed -i 's#ErrorLog ${APACHE_LOG_DIR}/error.log#ErrorLog /dev/stderr#g' /etc/apache2/apache2.conf
RUN echo 'TransferLog /dev/stdout'  >> /etc/apache2/apache2.conf
RUN a2enmod ssl rewrite headers proxy_http authz_groupfile remoteip
RUN a2ensite roundcube
RUN composer require --no-interaction \
    pear/http_request2 \
    caxy/php-htmldiff \
    lolli42/finediff \
    sabre/vobject

ENTRYPOINT ["/start.sh"]
