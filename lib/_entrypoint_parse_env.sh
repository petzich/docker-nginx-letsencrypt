#!/bin/sh

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
