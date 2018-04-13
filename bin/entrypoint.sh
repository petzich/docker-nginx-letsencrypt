#!/bin/sh

libdir=/usr/local/lib

. $libdir/_cert_functions.sh
. $libdir/_entrypoint_derived_images.sh
. $libdir/_entrypoint_log_setup.sh
. $libdir/_entrypoint_global_vars.sh
. $libdir/_entrypoint_parse_env.sh
. $libdir/_nginx_cfg_main.sh
. $libdir/_nginx_cfg_http.sh
. $libdir/_nginx_cfg_https.sh
. $libdir/_nginx_cfg_backend.sh
. $libdir/_nginx_cfg_ssl.sh
. $libdir/_nginx_cfg_static.sh

# Create configuration files for HTTP mode
function create_config_files_builtin(){
	logger_info "Generating builtin nginx configuration"
	echo "$(nginx_cfg_main $PROXY_AUTH_USER $PROXY_AUTH_PASSWORD $PROXY_DOMAIN)" > /etc/nginx/nginx.conf
	echo "$(nginx_cfg_http_default $PROXY_DOMAIN $PROXY_HTTP_PORT $PROXY_HTTPS_PORT)" > /etc/nginx/conf.d/http_default.conf
	echo "$(nginx_cfg_https_default $PROXY_DOMAIN $PROXY_HTTPS_PORT)" > /etc/nginx/conf.d/http_default_ssl.conf
	echo "$(nginx_cfg_backend_string "$PROXY_BACKENDS" $PROXY_TUNING_UPSTREAM_MAX_CONNS)" > /etc/nginx/conf.d/http_default_backend.conf
	echo "$(nginx_cfg_static_string "$PROXY_STATIC_DIRS")" > /etc/nginx/conf.d/default_static_dirs.conf.inc
}

logger_info "(Nginx-Letsencrypt) starting entrypoint.sh"
prepare_proxy_variables
env_replace_names=$(prepare_envreplace)
create_acme_challenge_dir
create_config_files_builtin

logger_info "Copying /extraconf"
copy_files "/extraconf" "/etc/nginx/conf.d"
logger_info "Replacing environment variables in files in /etc/nginx/conf.d/*.orig"
files_replace_vars "/etc/nginx/conf.d" "orig" "$env_replace_names"

# Does the certificate exist already?
certificate_exists $le_privkey $le_fullchain
cert_exists=$?
if [ $cert_exists -eq 255 ]
then
	logger_info "No certificate exists yet, generating new certificate"
	ssl_conf_disable
	exec nginx &
	sleep 1
	certificate_create $le_privkey $le_fullchain $cert_method
	# generate_certificate
	killall nginx
	sleep 1
	ssl_conf_enable
fi

logger_info "Copying additional html files from /extrahtml"
copy_files /extrahtml /var/www/html

# And last but not least the most important action: call nginx.
logger_info "(Nginx-Letsencrypt) at end of entrypoint.sh"
logger_info "(Nginx-Letsencrypt) running command: $@"
exec "$@"
