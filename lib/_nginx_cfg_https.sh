#!/bin/sh

# Configure main https section
# Parameters:
# $1: domain
# $2: https port
nginx_cfg_https_default() {
	local domain=$1
	local https_port=$2
	retval="
server {
  listen $https_port;
  ssl on;
  ssl_certificate     /etc/letsencrypt/live/$domain/fullchain.pem;
  ssl_certificate_key /etc/letsencrypt/live/$domain/privkey.pem;

  include conf.d/default_static_dirs.conf.inc;

  location / {
    proxy_pass http://backend_server/;
    proxy_set_header Host $domain;
    proxy_set_header X-Forwarded-Proto \$scheme;

    # Extension point for derived images
    include conf.d/ssl_*.conf.inc;
  }

  # redirect server error pages to the static page /50x.html
  #
  error_page   500 502 503 504  /50x.html;
  location = /50x.html {
    auth_basic off;
    root   /usr/share/nginx/html;
  }
}
"
	echo "$retval"
}
