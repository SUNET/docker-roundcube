FROM roundcube/roundcubemail:1.6.9-apache AS build

ARG DOMAIN=localhost

RUN apt-get update && apt-get install -y \
    libapache2-mod-shib \
    mkcert
RUN mkcert -cert-file /etc/ssl/certs/cert.pem \
	  -key-file /etc/ssl/private/cert.key \
    ${DOMAIN}

FROM build AS config
COPY ./shib.conf /etc/apache2/sites-enabled/shib.conf

