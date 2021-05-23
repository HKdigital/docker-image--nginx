#!/bin/bash

CONFIG_FOLDER=/@config

nginx -t -c "${CONFIG_FOLDER}/nginx.conf" \
&& nginx -s reload \
&& echo "Reloaded NGINX configuration"