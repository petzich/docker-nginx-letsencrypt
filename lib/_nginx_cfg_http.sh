#!/bin/sh

# Generate redirect to https
# Parameters
# $1: https_port
nginx_cfg_http_https_redirect() {
	local https_port=$1
	retval="    location / {
        return 302 https://\$server_name:$https_port\$request_uri;
    }
"
	echo "$retval"
}

# Generate default http section
# Parameters:
# $1: domainname
# $2: http_port
# $3: https_port
nginx_cfg_http_default() {
	local domain=$1
	local http_port=$2
	local https_port=$3
	retval="server {
    auth_basic off;
    listen $http_port;
    ssl off;
    server_name $domain;

    location /.well-known/ {
        auth_basic off;
        root /var/www/html;
    }

$(nginx_cfg_http_https_redirect $https_port)

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
