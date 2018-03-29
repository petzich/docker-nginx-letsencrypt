#!/bin/sh

libdir=/usr/local/lib

. $libdir/_entrypoint_log_setup.sh
. $libdir/_entrypoint_global_vars.sh
. $libdir/_entrypoint_parse_env.sh

# Prepare envsubst to replace all variables beginning with PROXY_
function prepare_envsubst(){
	# All env vars beginning with PROXY_
	es_vars=`env | grep -Eo "^PROXY_.*=" | sed -E 's/^(PROXY_.*?)=/\1/g'`
	es_string=""
	for i in $es_vars; do
		es_string="$es_string\$$i"
	done
	envsubst_cmd="envsubst '$es_string'"
	logger_debug "Command for running envsubst: $envsubst_cmd"
}

# Create the directory for acme challenges
function create_acme_challenge_dir(){
	logger_debug "Generating acme-challenge directory"
	mkdir -p /var/www/html/.well-known/acme-challenge
	chown -R nginx:nginx /var/www/html/.well-known
}

# Set basic_auth in the global http section
function set_basic_auth(){
	if [ ! -z ${PROXY_AUTH_USER} ]
	then
		logger_info "Setting HTTP basic protection (user: $PROXY_AUTH_USER)"
		# Create the file first
		echo "$PROXY_AUTH_USER:{PLAIN}$PROXY_AUTH_PASSWORD" > /etc/nginx/conf.d/auth_basic.inc
		# Then configure auth_basic in the HTTP section
		if [ `grep -c "auth_basic" $nginx_conf` -lt 1 ]
		then
			# First time
			sed -i '/^http/a \auth_basic "test";' $nginx_conf
			sed -i '/^auth_basic\ /a \auth_basic_user_file /etc/nginx/conf.d/auth_basic.inc;' $nginx_conf
		else
			sed -i 's/^auth_basic.*$\ /auth_basic "test";/' $nginx_conf
			sed -i 's/^auth_basic_user_file.*$\ /auth_basic_user_file /etc/nginx/conf.d/auth_basic.inc;/' $nginx_conf
		fi
	fi
}

# Create configuration files for HTTP mode
function create_config_files_builtin(){
	logger_debug "Generating nginx configuration files for http mode"
	$envsubst_cmd < /etc/nginx/nginx.conf.orig > /etc/nginx/nginx.conf
	$envsubst_cmd < /etc/nginx/conf.d/http_default.conf.orig > /etc/nginx/conf.d/http_default.conf
	$envsubst_cmd < /etc/nginx/conf.d/http_default_ssl.conf.orig > /etc/nginx/conf.d/http_default_ssl.conf
}

. $libdir/_nginx_cfg_backend.sh
function create_config_backend(){
	backend_config_string=$(nginx_cfg_backend_string)
	logger_debug "backend_config_string: $backend_config_string"
	echo -e "$backend_config_string" > /etc/nginx/conf.d/http_default_backend.conf
}

# Disable all files that have ssl configuration if the certificate does not exist on filesystem
function disable_ssl_config(){
	if [ ! -f $le_privkey ] || [ ! -f $le_fullchain ]
	then
		files_with_cert_refs=`grep -l "ssl_certificate" /etc/nginx/conf.d/*`
		for f in $files_with_cert_refs; do
			logger_info "-- Temporarily disabling config (no ssl certificate exists yet)"
			logger_info "- src:  $f"
			logger_info "- dst: $f.disabled"
			mv $f "$f.disabled"
		done
	fi
}

# Generate a certificate
function generate_certificate(){
	# In PROXY_MODE dev generate self-signed using openssl
	# In any other mode, generate using certbot
	if [ ! -z ${PROXY_MODE} ] && [ ${PROXY_MODE} = "dev" ]
	then
		mkdir -p $le_path
		if [ -f $le_privkey ]
		then
			logger_warn "Private key already exists, not overwriting ($le_privkey)"
		else
			logger_info "Generating self-signed certificate"
			openssl req -subj $le_dev_subject -x509 -sha256 -newkey rsa:1024 -nodes -keyout $le_privkey -out $le_fullchain -days 365
		fi
	elif [ -f "$le_fullchain" ]
	then
		logger_info "Renewing certificate"
		certbot renew
	else
		# certbot is run with the following options:
		# certonly (installing in nginx is not yet supported)
		# -n        = non-interactive (this is a script, after all)
		# --webroot = webroot method to /var/www/html
		# -d        = domain is passed as ENV variable
		# --agree-tos   = agree to terms of service (non-interactive)
		# -m            = mail address for letsencrypt account
		# --keep        = do not replace existing certificate, unless expiry is close
		logger_info "Generating certificate"
		certbot certonly -n --webroot -w /var/www/html -d ${PROXY_DOMAIN} --agree-tos -m ${PROXY_CERTBOT_MAIL} --keep
	fi
}

function enable_disabled_config(){
	disabled_files=`ls -1 /etc/nginx/conf.d/*.disabled 2>/dev/null`
	for f in $disabled_files; do
		output_filename=`echo $f | rev | cut -c 10- | rev`
		logger_info "-- Re-enabling disabled config:"
		logger_info "- src:  $f"
		logger_info "- dst: $output_filename"
		mv $f $output_filename
	done
}

# Some setup after certificate generation
function post_certificate_setup(){
	# Redirect to https port
	sed -i "s/^.*return.*$/        return 301 https:\/\/\$server_name:${PROXY_HTTPS_PORT}\$request_uri;/" /etc/nginx/conf.d/http_default.conf
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

# Copy extra configuration (mostly from derived image)
function prepare_extraconf(){
	if [ -d /extraconf ]
	then
		logger_info "Copying /extraconf to /etc/nginx/conf.d"
		cp /extraconf/* /etc/nginx/conf.d/
		cd /etc/nginx/conf.d/
		for i in `ls -1 stream_*.conf.orig ssl_*.conf.inc.orig`; do
			output_filename=`echo $i | rev | cut -c 6- | rev`
			logger_info "Replacing env vars: $i -> $output_filename"
			$envsubst_cmd < $i > $output_filename
		done
		cd
	fi
}

# Copy extrahtml
function copy_extrahtml(){
	if [ -d /extrahtml ]
	then
		cp -a /extrahtml/* /var/www/html/
	fi
}

logger_info "(Nginx-Letsencrypt) starting entrypoint.sh"
prepare_proxy_variables
prepare_envsubst
create_acme_challenge_dir
create_config_files_builtin
set_basic_auth
create_config_backend
create_static_files_entries
prepare_extraconf

disable_ssl_config
logger_debug "Starting nginx in background for certificate generation"
exec nginx &
sleep 1
generate_certificate
killall nginx
sleep 1
enable_disabled_config
post_certificate_setup

copy_extrahtml

# And last but not least the most important action: call nginx.
logger_info "(Nginx-Letsencrypt) at end of entrypoint.sh"
logger_info "(Nginx-Letsencrypt) running command: $@"
exec "$@"
