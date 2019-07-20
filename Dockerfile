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

COPY rootfs/ /

RUN set -x \
 # "disable" nginx default server config, copy default php-fpm configs
 && mv /etc/nginx/conf.d/default.conf /etc/nginx/sites-enabled/default.conf.disabled \
 && cp /etc/php/${PHP_VERSION}/php-fpm.conf /etc/php/${PHP_VERSION}/php-fpm.conf.default \
 && cp /etc/php/${PHP_VERSION}/php-fpm.d/www.conf /etc/php/${PHP_VERSION}/php-fpm.d/www.conf.default \
 # change default configs
 && echo 'fastcgi_param  SCRIPT_FILENAME $document_root$fastcgi_script_name;' >> /etc/nginx/fastcgi_params \
 && echo 'include=/app/config/php-fpm/' >> /etc/php/${PHP_VERSION}/php-fpm.conf \
 && sed -i -E 's/;?daemonize = .+/daemonize = no/g' /etc/php/${PHP_VERSION}/php-fpm.conf \
 && sed -i -E 's/;?error_log = .+/error_log = \/dev\/stdout/g' /etc/php/${PHP_VERSION}/php-fpm.conf \
 && sed -i -E 's/;?listen.owner = .+/listen.owner = nginx/g' /etc/php/${PHP_VERSION}/php-fpm.d/www.conf \
 && sed -i -E 's/;?listen.group = .+/listen.group = nginx/g' /etc/php/${PHP_VERSION}/php-fpm.d/www.conf \
 # add nginx and www-data to abc group, change www-data home dir
 && usermod --append --groups abc nginx \
 && usermod \
    --append \
    --groups abc \
    --home /dev/null \
    www-data

EXPOSE 80 443
