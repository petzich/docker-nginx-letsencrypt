#!/bin/sh

nginx_cfg_http_https_redirect() {
	retval="    location / {
        return 302 https://\$server_name:${PROXY_HTTPS_PORT}\$request_uri;
    }
"
	echo "$retval"
}

nginx_cfg_http_default() {
	retval="server {
    auth_basic off;
    listen ${PROXY_HTTP_PORT};
    ssl off;
    server_name ${PROXY_DOMAIN};

    location /.well-known/ {
        auth_basic off;
        root /var/www/html;
    }

$(nginx_cfg_http_https_redirect)

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
