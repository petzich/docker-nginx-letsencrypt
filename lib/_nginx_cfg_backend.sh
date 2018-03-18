#!/bin/sh

nginx_cfg_backend_string_core () {
	retval=""
	for backend in $PROXY_BACKENDS; do
		retval="${retval}server ${backend} max_fails=3 fail_timeout=5s max_conns=${PROXY_TUNING_UPSTREAM_MAX_CONNS};\n"
	done
	echo $retval
}

nginx_cfg_backend_string () {
	backend_string_core=$(nginx_cfg_backend_string_core)
	retval="upstream backend_server {\n ip_hash;\n"
	retval="$retval $backend_string_core"
	retval="$retval}"
	echo $retval
}
