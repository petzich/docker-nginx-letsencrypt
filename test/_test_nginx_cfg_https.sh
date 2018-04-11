#! /bin/sh

. ${libdir}/_nginx_cfg_https.sh

setUp(){
	unset PROXY_DOMAIN
	unset PROXY_HTTP_PORT
	unset PROXY_HTTPS_PORT
}

# Test the https default section
testHttpsDefault(){
	expected="
server {
  listen 5443;
  ssl on;
  ssl_certificate     /etc/letsencrypt/live/ssl.example.org/fullchain.pem;
  ssl_certificate_key /etc/letsencrypt/live/ssl.example.org/privkey.pem;

  include conf.d/default_static_dirs.conf.inc;

  location / {
    proxy_pass http://backend_server/;
    proxy_set_header Host ssl.example.org;
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
}"
	actual=$(nginx_cfg_https_default ssl.example.org 5443)
	assertEquals "$expected" "$actual"
}

. ${extlibdir}/shunit2/shunit2
