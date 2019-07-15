ARG PHP_VERSION="7.1"
FROM roeldev/php-cli:${PHP_VERSION}-v1

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
 && apk add \
    --no-cache \
        php${PHP_VERSION}-fpm \
        nginx \
 # ensure www-data user and group exists, 82 is the standard uid/gid in Alpine
 && addgroup \
    -S \
    -g 82 \
    www-data \
 && adduser \
    -D -S \
    -u 82 \
    -G www-data \
    www-data

COPY rootfs/ /
