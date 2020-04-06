#!/bin/bash
set -e

/etc/init.d/php${PHP_VERSION}-fpm start
/usr/sbin/nginx -g 'daemon off;'
