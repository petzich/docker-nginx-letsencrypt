#!/bin/sh

nginx_cfg_backend_string_core () {
	retval=""
	counter=0
	for backend in $PROXY_BACKENDS; do
		if [ $counter -gt 0 ]; then
			retval="${retval}\n"
		fi
		retval="${retval}server ${backend} max_fails=3 fail_timeout=5s max_conns=${PROXY_TUNING_UPSTREAM_MAX_CONNS};"
		counter=$(expr $counter + 1)
	done
	echo -en $retval
}

nginx_cfg_backend_string () {
	backend_string_core="$(nginx_cfg_backend_string_core)"
	retval="upstream backend_server {\n"
	retval="${retval}ip_hash;\n"
	retval="${retval}${backend_string_core}\n}"
	echo -en $retval
}
