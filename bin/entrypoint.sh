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

# Create configuration files for HTTP mode
function create_config_files_builtin(){
	logger_info "Generating builtin nginx configuration"
	echo "$(nginx_cfg_main)" > /etc/nginx/nginx.conf
	echo "$(nginx_cfg_http_default)" > /etc/nginx/conf.d/http_default.conf
	echo "$(nginx_cfg_https_default)" > /etc/nginx/conf.d/http_default_ssl.conf
	echo "$(nginx_cfg_backend_string)" > /etc/nginx/conf.d/http_default_backend.conf
}

# Disable all files that have ssl configuration if the certificate does not exist on filesystem
function disable_ssl_config(){
	if [ ! -f $le_privkey ] || [ ! -f $le_fullchain ]
	then
		logger_info "Temporarily disabling configuration files with references to certificates."
		files_with_cert_refs=`grep -l "ssl_certificate" /etc/nginx/conf.d/*`
		for f in $files_with_cert_refs; do
			logger_debug "Temporarily disabling: $f (rename to: $f.disabled)"
			mv $f "$f.disabled"
		done
	fi
}

function enable_disabled_config(){
	logger_info "Re-Enabling disabled configuration"
	disabled_files=`ls -1 /etc/nginx/conf.d/*.disabled 2>/dev/null`
	for f in $disabled_files; do
		output_filename=`echo $f | rev | cut -c 10- | rev`
		logger_debug "Re-enabling $f (rename to $output_filename)"
		mv $f $output_filename
	done
}

# Create the entries for static files
function create_static_files_entries(){
	# Create the entries for static files
	stat="/etc/nginx/conf.d/default_static_dirs.conf.inc"
	echo "" > $stat
	for i in $PROXY_STATIC_DIRS
	do
		location=`echo $i | awk -F"," '{print $1}'`
		directory=`echo $i | awk -F"," '{print $2}'`
		logger_info "Creating static entry: $location -> $directory"
		echo "location /$location/ { root $directory; }" >> $stat
	done
}

logger_info "(Nginx-Letsencrypt) starting entrypoint.sh"
prepare_proxy_variables
env_replace_names=$(prepare_envreplace)
create_acme_challenge_dir
create_config_files_builtin
create_static_files_entries

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
	disable_ssl_config
	exec nginx &
	sleep 1
	certificate_create $le_privkey $le_fullchain $cert_method
	# generate_certificate
	killall nginx
	sleep 1
	enable_disabled_config
fi

logger_info "Copying additional html files from /extrahtml"
copy_files /extrahtml /var/www/html

# And last but not least the most important action: call nginx.
logger_info "(Nginx-Letsencrypt) at end of entrypoint.sh"
logger_info "(Nginx-Letsencrypt) running command: $@"
exec "$@"
