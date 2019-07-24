ARG PHP_TAG="7.1"
FROM roeldev/php-cli:${PHP_TAG}-v1 as builder

RUN set -x \
 && apk update \
 && apk add \
    --no-cache \
        git \
&& git clone --branch 3.1.0 https://github.com/h5bp/server-configs-nginx.git /tmp/h5bp

WORKDIR /tmp/h5bp/
RUN set -x \
 && echo "daemon off;" >> nginx.conf \
 && mkdir sites-default \
 # rename default/example vhost configs
 && mv conf.d/.default.conf sites-default/ssl-default.conf.example \
 && mv conf.d/no-ssl.default.conf sites-default/no-ssl-default.conf.example \
 && mv conf.d/templates/example.com.conf sites-default/ssl-app.conf.example \
 && mv conf.d/templates/no-ssl.example.com.conf sites-default/no-ssl-app.conf.example \
 # move only the files we need
 && mkdir -p /root-out/etc/nginx/ \
 && mv -t /root-out/etc/nginx/ \
    mime.types \
    nginx.conf \
    sites-default \
    h5bp \
 && chmod -R 0644 /root-out/etc/nginx

###############################################################################
# create actual image
###############################################################################
ARG PHP_TAG="7.1"
FROM roeldev/php-cli:${PHP_TAG}-v1

ADD https://nginx.org/keys/nginx_signing.rsa.pub /etc/apk/keys/nginx_signing.rsa.pub

ARG PHP_VERSION="7.1"
ARG NGINX_VERSION="1.17.1"

RUN set -x \
 # verify repository key
 && EXPECTED_KEY="e7fa8303923d9b95db37a77ad46c68fd4755ff935d0a534d26eba83de193c76166c68bfe7f65471bf8881004ef4aa6df3e34689c305662750c0172fca5d8552a *stdin" \
 && ACTUAL_KEY=$( openssl rsa -pubin -in /etc/apk/keys/nginx_signing.rsa.pub -text -noout | openssl sha512 -r ) \
 && if [ "${ACTUAL_KEY}" = "${EXPECTED_KEY}" ]; then echo "key verification succeeded!"; \
    else echo "key verification failed!"; exit 1; fi \
 # add repository
 && echo "https://nginx.org/packages/mainline/alpine/v$( alpine_version )/main" >> /etc/apk/repositories \
 # install dependencies
 && apk update \
 && apk add \
    --no-cache \
        php${PHP_VERSION}-fpm \
        nginx

RUN set -x \
 # update default php-fpm settings
 && sed -i -E 's/;?daemonize = .+/daemonize = no/g' /etc/php/${PHP_VERSION}/php-fpm.conf \
 && sed -i -E 's/;?error_log = .+/error_log = \/dev\/stdout warn/g' /etc/php/${PHP_VERSION}/php-fpm.conf \
 # move all php-fpm config files to /etc/php-fpm.d and create a symlink to the
 # original php/php-fpm.d folder. this way we have a config folder without
 # the php version in it's path
 && mv /etc/php/${PHP_VERSION}/php-fpm.d /etc/php-fpm.d \
 && ln -s /etc/php-fpm.d /etc/php/${PHP_VERSION}/php-fpm.d \
 && chmod -R 0644 /etc/php-fpm.d \
 && sed -i -E 's/;?listen.owner = .+/listen.owner = nginx/g' /etc/php-fpm.d/www.conf \
 && sed -i -E 's/;?listen.group = .+/listen.group = nginx/g' /etc/php-fpm.d/www.conf

COPY --from=builder /root-out/ /

RUN set -x \
  # add nginx and www-data to abc group, change www-data home dir
 && usermod \
    --append \
    --groups abc \
    nginx \
 && usermod \
    --append \
    --groups abc \
    --home /dev/null \
    www-data \
 # update default nginx settings
 && rm /etc/nginx/conf.d/default.conf \
 && sed -i -e 's/user www-data/user nginx/g' /etc/nginx/nginx.conf \
 && sed -i -e 's/user www-data/user nginx/g' /etc/nginx/nginx.conf \
 && echo 'fastcgi_param  SCRIPT_FILENAME $realpath_root$fastcgi_script_name;' >> /etc/nginx/fastcgi_params \
 && echo 'fastcgi_param  DOCUMENT_ROOT $realpath_root;' >> /etc/nginx/fastcgi_params \
 # add symlinks for certificates to nginx
 && mkdir -p /etc/nginx/certs/ \
 && ln -s /app/config/certs/default.crt /etc/nginx/certs/default.crt \
 && ln -s /app/config/certs/default.key /etc/nginx/certs/default.key

COPY rootfs/ /

EXPOSE 80 443
