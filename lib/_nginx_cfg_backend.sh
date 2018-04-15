#!/bin/sh

# Configure a single backend line
# Parameters:
# $1: backend (hostname)
# $2: max_conns
# $3: (optional) the string 'down' to mark the backend as unavailable
nginx_cfg_single_backend_line() {
	local backend=$1
	local max_conns=$2
	local down=$3
	local retval="server ${1} max_fails=3 fail_timeout=5s max_conns=$max_conns"
	if [ "$down" = "down" ]
	then
		local retval="${retval} down;"
	else
		local retval="${retval};"
	fi
	echo "${retval}"
}

# Matches a "enable_backend" or "disable_backend" string against a certain backend and returns the keyword "down" if the backend should be disabled
# Input:
# $1: backend to match
# $2: command string (enable_x or disable_x)
# Example 1: enable_backend1
# nginx_cfg_backend_enable_matcher backend1 enable_backend1 => ''
# nginx_cfg_backend_enable_matcher backend2 enable_backend1 => 'down'
# nginx_cfg_backend_enable_matcher backend3 enable_backend1 => 'down'
# Example 2: disable_backend1
# nginx_cfg_backend_enable_matcher backend1 disable_backend1 => 'down'
# nginx_cfg_backend_enable_matcher backend2 disable_backend1 => ''
# nginx_cfg_backend_enable_matcher backend3 disable_backend1 => ''
nginx_cfg_backend_enable_matcher() {
	local fun="nginx_cfg_backend_enable_matcher()"
	local backend=$1
	local command=$2
	local enable_match=$(echo "$command" | sed -rn 's/^enable_(.*)$/\1/p')
	local disable_match=$(echo "$command" | sed -rn 's/^disable_(.*)$/\1/p')
	logger_trace "enable_match: $enable_match, disable_match: $disable_match"
	local retval=""
	# Check we can match anything at all, or return with 1 (error)
	if [ ! -z "$enable_match" ] && [ ! -z "$disable_match" ]
	then
		logger_warn "$fun: no proper command 'enable_' or 'disable_' given. Not matching anything."
		return 1
	# enable_match with non-matching backend => down
	elif [ ! -z "$enable_match" ] && [ ! "$enable_match" = "$backend" ]
	then
		local retval="down"
	# disable_match with matching backend => down
	elif [ ! -z "$disable_match" ] && [ "$disable_match" =	"$backend" ]
	then
		local retval="down"
	fi
	echo "${retval}"
}

# Create the config section with the backends
# Parameters:
# $1: List of backends (space-separated, but in quotes)
# $2: max_conns (per backend)
# $3: (optional) A command to enable or disable *only* a certain backend. If enabling only a certain backend, all other backends will be disabled. If disabling only a certain backend, all other backends will be enabled.
# Example: nginx_cfg_backend_string "backend1 backend2" 50
# Example: nginx_cfg_backend_string "backend1 backend2" 50 enable_backend1
# Example: nginx_cfg_backend_string "backend1 backend2 backend3" 50 disable_backend3
nginx_cfg_backend_string () {
	local fun="nginx_cfg_backend_string()"
	local backends=$1
	local max_conns=$2
	local command_string=$3
	retval="upstream backend_server {
  ip_hash;"
	for backend in $backends; do
		local down=$(nginx_cfg_backend_enable_matcher $backend $command_string)
		retval="${retval}
  $(nginx_cfg_single_backend_line $backend $max_conns $down)"
	done
	retval="${retval}
}"
	echo "$retval"
}
