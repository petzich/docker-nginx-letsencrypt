#!/bin/sh

libdir=/usr/local/lib

. $libdir/_cert_functions.sh
. $libdir/_entrypoint_log_setup.sh
. $libdir/_entrypoint_global_vars.sh
. $libdir/_entrypoint_parse_env.sh

prepare_proxy_variables

# Does the certificate exist already?
certificate_exists $le_privkey $le_fullchain
cert_exists=$?
if [ $cert_exists -eq 0 ]
then
	logger_info "Renewing certificates"
	certificate_renew $le_privkey $le_fullchain $cert_method
	nginx -t && nginx -s reload
fi

