#!/usr/bin/with-contenv bash

keyFile=/app/config/certs/default.key
csrFile=/app/config/certs/default.csr
crtFile=/app/config/certs/default.crt
configFile=/app/config/certs/openssl.cnf

if [[ -f ${keyFile} && -f $csrFile ]]
then
    echo "Using certificates found in /app/config/certs/"
else
    echo
    echo "Generating self-signed certificates in /app/config/certs/,"
    echo "you can replace these with your own if required"
    echo

    openssl genrsa -out ${keyFile} 2048
    openssl req -new -config ${configFile} -key ${keyFile} -out ${csrFile}
    openssl req -in ${csrFile} -noout -text
    openssl x509 -req -days 3650 -in ${csrFile} -signkey ${keyFile} -out ${crtFile} -extensions v3_req -extfile ${configFile}

    # openssl req \
    #     -new \
    #     -x509 \
    #     -days 3650 \
    #     -nodes \
    #     -config ${configFile} \
    #     -out ${csrFile} \
    #     -keyout ${keyFile}
        # > /dev/null 2>&1
fi
