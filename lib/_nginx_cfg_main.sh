#!/bin/sh

. $libdir/_nginx_cfg_auth_basic.sh

# Main http section
# Parameters (optional):
# $1: basic auth user
# $2: basic auth password
# $3: basic auth realm
nginx_cfg_http_section(){
	local user=$1
	local password=$2
	local realm=$3
	retval="http {

$(nginx_cfg_auth_basic $user $password $realm)

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

# Main configuraton
# Parameters. Either all or none must be supplied
# $1: basic auth user
# $2: basic auth password
# $3: basic auth realm
nginx_cfg_main() {
	local user=$1
	local password=$2
	local realm=$3
	retval="
daemon off;
user nginx;
worker_processes 1;
error_log /var/log/nginx/error.log warn;
pid       /var/run/nginx.pid;

events {
  worker_connections 128;
}

$(nginx_cfg_http_section $user $password $realm)

stream {
  include /etc/nginx/conf.d/stream_*.conf;
}
"
	echo "$retval"
}
