#!/usr/bin/with-contenv bash

if [[ ! -d /config/nginx ]]
then
    echo "Using default nginx configs from /etc/nginx/conf.d/"

    cp \
        --archive \
        --no-clobber \
        $( if ${VERBOSE_INIT:-false}; then echo '--verbose'; fi ) \
        /etc/nginx/sites-default/*.conf /etc/nginx/conf.d

    exit 0
fi

echo
echo "Using custom nginx configs from /config/nginx/,"
echo "you may change these to your needs"
echo

# create symlink to custom config folder
rm -rf /etc/nginx/conf.d/
ln -s /config/nginx /etc/nginx/conf.d

# add the default configs when the custom config folder is still empty
if [[ $( ls /config/nginx ) == "" ]]
then
    cp \
        --archive \
        --no-clobber \
        $( if ${VERBOSE_INIT:-false}; then echo '--verbose'; fi ) \
        /etc/nginx/sites-default/. /config/nginx/
fi
