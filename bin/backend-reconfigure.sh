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
FLAGS_HELP="usage: $0 [flags]
The flags are mutually exclusive. All backends will be reconfigured at once."

FLAGS "$@" || exit $?
eval set -- "${FLAGS_ARGV}"

# Count all options that are set
count=0
echo "FLAGS_enable: ${FLAGS_enable}"
if [ ! "${FLAGS_enable}" = "" ]; then count=$(($count + 1)); fi
echo "FLAGS_disable: ${FLAGS_disable}"
if [ ! "${FLAGS_disable}" = "" ]; then count=$(($count + 1)); fi
echo "FLAGS_all: ${FLAGS_all}"
if [ ${FLAGS_all} -eq 0 ]; then count=$(($count + 1)); fi

# Exit in case of wrong number of flags
if [ $count -eq 0 ]
then
	echo "Please provide at least one flag"
	exit 1
elif [ $count -ge 2 ]
then
	echo "Please provide only one flag"
	exit 1
fi

# Reconfigure the backend
if [ ! "${FLAGS_enable}" = "" ]
then
	echo "$(nginx_cfg_backend_string "$PROXY_BACKENDS" $PROXY_TUNING_UPSTREAM_MAX_CONNS enable_${FLAGS_enable})" > /etc/nginx/conf.d/http_default_backend.conf
elif [ ! "${FLAGS_disable}" = "" ]
then
	echo "$(nginx_cfg_backend_string "$PROXY_BACKENDS" $PROXY_TUNING_UPSTREAM_MAX_CONNS disable_${FLAGS_disable})" > /etc/nginx/conf.d/http_default_backend.conf
elif [ ${FLAGS_all} -eq 0 ]
then
	echo "$(nginx_cfg_backend_string "$PROXY_BACKENDS" $PROXY_TUNING_UPSTREAM_MAX_CONNS)" > /etc/nginx/conf.d/http_default_backend.conf
fi
