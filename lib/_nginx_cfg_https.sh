#!/bin/sh

nginx_cfg_https_default() {
	retval="
server {
  listen ${PROXY_HTTPS_PORT};
  ssl on;
  ssl_certificate     /etc/letsencrypt/live/${PROXY_DOMAIN}/fullchain.pem;
  ssl_certificate_key /etc/letsencrypt/live/${PROXY_DOMAIN}/privkey.pem;

  include conf.d/default_static_dirs.conf.inc;

  location / {
    proxy_pass http://backend_server/;
    proxy_set_header Host ${PROXY_DOMAIN};
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
