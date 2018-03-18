#!/bin/sh

libdir=/usr/local/lib

. $libdir/_entrypoint_global_vars.sh
. $libdir/_entrypoint_debug.sh

# Prepare environment variables and set up defaults
function prepare_proxy_variables(){
	for ev in $env_vars; do
		echo_debug "$ev: \$$ev"
	done
	# PROXY_DOMAIN must be set, or there is no use in starting the proxy.
	# In PROXY_MODE==dev, this value is overriden to "localhost".
	if [ -z ${PROXY_DOMAIN} ]
	then
		echo_error "PROXY_DOMAIN is not set"
		exit 1
	else
		le_path="/etc/letsencrypt/live/$PROXY_DOMAIN"
		le_privkey="$le_path/privkey.pem"
		le_fullchain="$le_path/fullchain.pem"
	fi

	# If PROXY_MODE is dev, then a self-signed certificate will be issued
	# to the domain localhost.
	if [ ! -z ${PROXY_MODE} ] && [ ${PROXY_MODE} = "dev" ]
	then
		echo_warn "Running in dev mode. Will use self-signed certificates."
		echo_warn "Not recommended for integration and production setup."
		echo_warn "Only localhost will be used as a host name."
	else
		if [ -z ${PROXY_CERTBOT_MAIL} ]
		then
			echo_error "PROXY_CERTBOT_MAIL is not set. It is required for letsencrypt"
			exit 1
		fi
	fi

	# PROXY_BACKENDS should be set.
	if [ -z ${PROXY_BACKENDS} ]
	then
		echo_error "PROXY_BACKENDS is not set."
		exit 1;
	fi

	# Default values for some variables
	if [ -z $PROXY_HTTP_PORT ]; then
		export PROXY_HTTP_PORT="80"
	fi
	if [ -z $PROXY_HTTPS_PORT ]; then
		export PROXY_HTTPS_PORT="443"
	fi
	if [ -z $PROXY_TUNING_WORKER_CONNECTIONS ]; then
		# Many docker containers have a 1024 file descriptor limit
		export PROXY_TUNING_WORKER_CONNECTIONS="512"
	fi
	if [ -z $PROXY_TUNING_UPSTREAM_MAX_CONNS ]; then
		export PROXY_TUNING_UPSTREAM_MAX_CONNS="0";
	fi

}

# Prepare envsubst to replace all variables beginning with PROXY_
function prepare_envsubst(){
	# All env vars beginning with PROXY_
	es_vars=`env | grep -Eo "^PROXY_.*=" | sed -E 's/^(PROXY_.*?)=/\1/g'`
	es_string=""
	for i in $es_vars; do
		es_string="$es_string\$$i"
	done
	envsubst_cmd="envsubst '$es_string'"
	echo_debug "Command for running envsubst: $envsubst_cmd"
}

# Create the directory for acme challenges
function create_acme_challenge_dir(){
	echo_debug "Generating acme-challenge directory"
	mkdir -p /var/www/html/.well-known/acme-challenge
	chown -R nginx:nginx /var/www/html/.well-known
}

# Set basic_auth in the global http section
function set_basic_auth(){
	if [ ! -z ${PROXY_AUTH_USER} ]
	then
		echo_info "Setting HTTP basic protection (user: $PROXY_AUTH_USER)"
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
	echo_debug "Generating nginx configuration files for http mode"
	$envsubst_cmd < /etc/nginx/nginx.conf.orig > /etc/nginx/nginx.conf
	$envsubst_cmd < /etc/nginx/conf.d/http_default.conf.orig > /etc/nginx/conf.d/http_default.conf
	$envsubst_cmd < /etc/nginx/conf.d/http_default_ssl.conf.orig > /etc/nginx/conf.d/http_default_ssl.conf
}

. $libdir/_nginx_cfg_backend.sh
function create_config_backend(){
	backend_config_string=$(nginx_cfg_backend_string)
	echo_debug "backend_config_string: $backend_config_string"
	echo -e "$backend_config_string" > /etc/nginx/conf.d/http_default_backend.conf
}

# Disable all files that have ssl configuration if the certificate does not exist on filesystem
function disable_ssl_config(){
	if [ ! -f $le_privkey ] || [ ! -f $le_fullchain ]
	then
		files_with_cert_refs=`grep -l "ssl_certificate" /etc/nginx/conf.d/*`
		for f in $files_with_cert_refs; do
			echo_info "-- Temporarily disabling config (no ssl certificate exists yet)"
			echo_info "- src:  $f"
			echo_info "- dst: $f.disabled"
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
			echo_warn "Private key already exists, not overwriting ($le_privkey)"
		else
			echo_info "Generating self-signed certificate"
			openssl req -subj $le_dev_subject -x509 -sha256 -newkey rsa:1024 -nodes -keyout $le_privkey -out $le_fullchain -days 365
		fi
	elif [ -f "$le_fullchain" ]
	then
		echo_info "Renewing certificate"
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
		echo_info "Generating certificate"
		certbot certonly -n --webroot -w /var/www/html -d ${PROXY_DOMAIN} --agree-tos -m ${PROXY_CERTBOT_MAIL} --keep
	fi
}

function enable_disabled_config(){
	disabled_files=`ls -1 /etc/nginx/conf.d/*.disabled 2>/dev/null`
	for f in $disabled_files; do
		output_filename=`echo $f | rev | cut -c 10- | rev`
		echo_info "-- Re-enabling disabled config:"
		echo_info "- src:  $f"
		echo_info "- dst: $output_filename"
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
		echo_info "Creating static entry: $location -> $directory"
		echo "location /$location/ { root $directory; }" >> $stat
	done
}

# Copy extra configuration (mostly from derived image)
function prepare_extraconf(){
	if [ -d /extraconf ]
	then
		echo_info "Copying /extraconf to /etc/nginx/conf.d"
		cp /extraconf/* /etc/nginx/conf.d/
		cd /etc/nginx/conf.d/
		for i in `ls -1 stream_*.conf.orig ssl_*.conf.inc.orig`; do
			output_filename=`echo $i | rev | cut -c 6- | rev`
			echo_info "Replacing env vars: $i -> $output_filename"
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

echo_with_prefix "(Nginx-Letsencrypt) starting entrypoint.sh"
prepare_loglevel
prepare_proxy_variables
prepare_envsubst
create_acme_challenge_dir
create_config_files_builtin
set_basic_auth
create_config_backend
create_static_files_entries
prepare_extraconf

disable_ssl_config
echo_debug "Starting nginx in background for certificate generation"
exec nginx &
sleep 1
generate_certificate
killall nginx
sleep 1
enable_disabled_config
post_certificate_setup

copy_extrahtml

# And last but not least the most important action: call nginx.
echo_with_prefix "(Nginx-Letsencrypt) at end of entrypoint.sh"
echo_with_prefix "(Nginx-Letsencrypt) running command: $@"
exec "$@"
