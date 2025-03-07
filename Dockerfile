FROM roundcube/roundcubemail:1.6.9-apache AS build

ARG DOMAIN="127.0.0.1 ::1 localhost mail.sunet.se mail.sunet.dev"

RUN apt-get update && apt-get install -y \
    expect \
    libapache2-mod-shib \
    mkcert
RUN mkcert -cert-file /etc/ssl/certs/cert.pem \
	  -key-file /etc/ssl/private/cert.key \
    ${DOMAIN}

FROM build AS config
COPY ./shib.conf /etc/apache2/sites-available/shib.conf
COPY ./md-signer2.crt /etc/shibboleth/md-signer2.crt
COPY ./shibboleth2.xml /etc/shibboleth/shibboleth2.xml
COPY ./start.sh /start.sh

RUN a2dissite 000-default
RUN a2disconf other-vhosts-access-log
RUN sed -i 's#ErrorLog ${APACHE_LOG_DIR}/error.log#ErrorLog /dev/stderr#g' /etc/apache2/apache2.conf
RUN echo 'TransferLog /dev/stdout'  >> /etc/apache2/apache2.conf
RUN sed -i 's/default_bits=3072/default_bits=4096/' /usr/sbin/shib-keygen
RUN a2enmod ssl rewrite headers proxy_http authz_groupfile remoteip
RUN a2ensite shib

ENTRYPOINT ["/start.sh"]
