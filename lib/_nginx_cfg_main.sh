#!/bin/sh

. $libdir/_nginx_cfg_auth_basic.sh

nginx_cfg_http_section(){
	retval="http {

$(nginx_cfg_auth_basic)

  include       /etc/nginx/mime.types;
  default_type  application/octet-stream;

  log_format  main  '\$remote_addr - \$remote_user [\$time_local] \"\$request\" '
                    '\$status \$body_bytes_sent \"\$http_referer\" '
                    '\"\$http_user_agent\" \"\$http_x_forwarded_for\" ';

  access_log  /var/log/nginx/access.log  main;

  server_tokens off;

  sendfile        on;
  keepalive_timeout  65;

  include /etc/nginx/conf.d/http_*.conf;
}
"
	echo "$retval"
}

nginx_cfg_main() {
	retval="
daemon off;
user nginx;
worker_processes 1;
error_log /var/log/nginx/error.log warn;
pid       /var/run/nginx.pid;

events {
  worker_connections 128;
}

$(nginx_cfg_http_section)

stream {
  include /etc/nginx/conf.d/stream_*.conf;
}
"
	echo "$retval"
}
