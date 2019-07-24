#!/usr/bin/with-contenv bash

if [[ -d /app/config/nginx ]]
then
    rm -rf /etc/nginx/conf.d/
    ln -s /app/config/nginx /etc/nginx/conf.d

    # a custom nginx config folder exists, check if it contains files
    if [[ $( ls /app/config/nginx ) == "" ]]
    then
        # copy default files
        cp \
            --archive \
            --no-clobber \
            $( if ${VERBOSE_INIT:-false}; then echo '--verbose'; fi ) \
            /etc/nginx/sites-default/. /app/config/nginx/
    fi
else
    cp \
        --archive \
        /etc/nginx/sites-default/. /etc/nginx/conf.d
fi
