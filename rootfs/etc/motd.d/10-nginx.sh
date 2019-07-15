#!/bin/sh

echo "Nginx version: $( nginx -v 2>&1 | cut -d'/' -f 2 )"
