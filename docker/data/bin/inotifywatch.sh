#!/bin/bash

while true; do
    inotifywatch /media
    php /var/www/bin/catalog_update.inc -a
    sleep 30
done