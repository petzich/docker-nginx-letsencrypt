#!/bin/sh

libdir=/usr/local/lib

. $libdir/shflags
. $libdir/_cert_functions.sh
. $libdir/_entrypoint_log_setup.sh
. $libdir/_entrypoint_global_vars.sh
. $libdir/_entrypoint_parse_env.sh
. $libdir/_nginx_cfg_backend.sh

prepare_proxy_variables

DEFINE_string 'enable' '' 'enable only this backend' 'e'
DEFINE_string 'disable' '' 'disable only this backend' 'd'
DEFINE_boolean 'all' 'false' 'enable all backends' 'a'
DEFINE_boolean 'list' 'false' 'list all available backends' 'l'

print_help(){
	echo "Enable or disable specific backends in nginx.
Settings are not persisted on container restart.

Examples:
$0 --enable host01.example.org		Enable only backend host01.example.org and disable all other backends
$0 --disable host01.example.org		Disable only backend host01.eample.org and enable all other backends
$0 --all 				Enable all backends
$0 --list				List all backends
$0					Print this help
"
}

FLAGS "$@" || exit $?
eval set -- "${FLAGS_ARGV}"

# Count all flags that are set
count=0
logger_debug "FLAGS_enable: ${FLAGS_enable}"
if [ ! "${FLAGS_enable}" = "" ]; then count=$(($count + 1)); fi
logger_debug "FLAGS_disable: ${FLAGS_disable}"
if [ ! "${FLAGS_disable}" = "" ]; then count=$(($count + 1)); fi
logger_debug "FLAGS_all: ${FLAGS_all}"
if [ ${FLAGS_all} -eq 0 ]; then count=$(($count + 1)); fi
logger_debug "FLAGS_list: ${FLAGS_list}"
if [ ${FLAGS_list} -eq 0 ]; then count=$(($count + 1)); fi

# Exit in case of wrong number of flags
if [ $count -eq 0 ]
then
	echo "No flags provided (exactly one flag required). Printing help."
	print_help
	exit 1
elif [ $count -ge 2 ]
then
	echo "Please provide exactly one flag"
	print_help
	exit 1
fi

# Test the configuration and reload nginx with new configuration
nginx_reload(){
	nginx -t && nginx -s reload
}

# Reconfigure the backend
if [ ! "${FLAGS_enable}" = "" ]
then
	logger_info "Enabling backend ${FLAGS_enable}. Disabling all other backends."
	echo "$(nginx_cfg_backend_string "$PROXY_BACKENDS" $PROXY_TUNING_UPSTREAM_MAX_CONNS enable_${FLAGS_enable})" > /etc/nginx/conf.d/http_default_backend.conf
	nginx_reload
elif [ ! "${FLAGS_disable}" = "" ]
then
	logger_info "Disabling backend ${FLAGS_disable}. Enabling all other backends."
	echo "$(nginx_cfg_backend_string "$PROXY_BACKENDS" $PROXY_TUNING_UPSTREAM_MAX_CONNS disable_${FLAGS_disable})" > /etc/nginx/conf.d/http_default_backend.conf
	nginx_reload
elif [ ${FLAGS_all} -eq 0 ]
then
	logger_info "Enabling all backends: $PROXY_BACKENDS"
	echo "$(nginx_cfg_backend_string "$PROXY_BACKENDS" $PROXY_TUNING_UPSTREAM_MAX_CONNS)" > /etc/nginx/conf.d/http_default_backend.conf
	nginx_reload
elif [ ${FLAGS_list} -eq 0 ]
then
	echo "Available backends:"
	for i in ${PROXY_BACKENDS}; do
		echo $i
	done
fi
