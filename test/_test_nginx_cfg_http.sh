#! /bin/sh

. ${libdir}/_nginx_cfg_http.sh

setUp(){
	unset PROXY_DOMAIN
	unset PROXY_HTTP_PORT
	unset PROXY_HTTPS_PORT
}

# Test the redirect string
testHttpHttpsRedirect(){
	export PROXY_HTTPS_PORT="12345"
	expected="    location / {
        return 302 https://\$server_name:12345\$request_uri;
    }"
	actual=$(nginx_cfg_http_https_redirect)
	assertEquals "$expected" "$actual"
}

# Test the default http configuration
testHttpDefault(){
	export PROXY_DOMAIN="test.example.org"
	export PROXY_HTTP_PORT="8080"
	export PROXY_HTTPS_PORT="8443"
	expected="server {
    auth_basic off;
    listen 8080;
    ssl off;
    server_name test.example.org;

    location /.well-known/ {
        auth_basic off;
        root /var/www/html;
    }

    location / {
        return 302 https://\$server_name:8443\$request_uri;
    }

    # redirect server error pages to the static page /50x.html
    #
    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        auth_basic off;
        root   /usr/share/nginx/html;
    }
}"
	actual=$(nginx_cfg_http_default)
	assertEquals "$expected" "$actual"
}

. ${extlibdir}/shunit2/shunit2
