#!/usr/bin/with-contenv bash

if [[ -d /app/config/nginx ]]
then
    echo
    echo "Using custom nginx configs from /app/config/nginx/,"
    echo "you may change these to your needs"
    echo

    # create symlink to custom config folder
    rm -rf /etc/nginx/conf.d/
    ln -s /app/config/nginx /etc/nginx/conf.d

    # add the default configs when the custom config folder is still empty
    if [[ $( ls /app/config/nginx ) == "" ]]
    then
        cp \
            --archive \
            --no-clobber \
            $( if ${VERBOSE_INIT:-false}; then echo '--verbose'; fi ) \
            /etc/nginx/sites-default/. /app/config/nginx/
    fi
else
    echo "Using default nginx configs from /etc/nginx/conf.d/"

    cp \
        --archive \
        $( if ${VERBOSE_INIT:-false}; then echo '--verbose'; fi ) \
        /etc/nginx/sites-default/. /etc/nginx/conf.d
fi
