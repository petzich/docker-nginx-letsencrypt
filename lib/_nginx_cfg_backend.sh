#!/bin/sh

# Configure a single backend line
# Parameters:
# $1: backend (hostname)
# $2: max_conns
nginx_cfg_single_backend_line() {
	local backend=$1
	local max_conns=$2
	echo "server ${1} max_fails=3 fail_timeout=5s max_conns=$max_conns;"
}

# Create the config section with the backends
# Parameters:
# $1: List of backends (space-separated, but in quotes)
# $2: max_conns (per backend)
# Example: nginx_cfg_backend_string "backend1 backend2" 50
nginx_cfg_backend_string () {
	local backends=$1
	local max_conns=$2
	retval="upstream backend_server {
  ip_hash;"
	for backend in $backends; do
		retval="${retval}
  $(nginx_cfg_single_backend_line $backend $max_conns)"
	done
	retval="${retval}
}"
	echo "$retval"
}
