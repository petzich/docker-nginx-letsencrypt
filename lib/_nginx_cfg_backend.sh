#!/bin/sh

nginx_cfg_backend_string () {
	backend_config_string="upstream backend_server {\n ip_hash;\n"
	for backend in $PROXY_BACKENDS; do
		backend_config_string="$backend_config_string server $backend max_fails=3 fail_timeout=5s max_conns=$PROXY_TUNING_UPSTREAM_MAX_CONNS;\n"
	done
	backend_config_string="$backend_config_string}"
	echo $backend_config_string
}
