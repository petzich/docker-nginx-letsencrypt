#!/bin/sh

# Create a single static line
# Parameters:
# $1: location
# $2: directory
# TODO: better error handling of input
nginx_cfg_static_single_line(){
	local location=$1
	local directory=$2
	echo "location /${location}/ { root ${directory}; }"
}

# Create the static entries string
# Parameters:
# $1: string of static mapping definitions. Use quotes around the whole string
nginx_cfg_static_string(){
	local fun="nginx_cfg_static_string()"
	local input=$1
	retval=""
	logger_debug "$fun: processing static string $input"
	for i in $input
	do
		local location=$(echo $i | awk -F"," '{print $1}')
		local directory=$(echo $i | awk -F"," '{print $2}')
		logger_debug "$fun: static mapping: $location -> $directory"
		local output=$(nginx_cfg_static_single_line $location $directory)
		retval="${retval}${output}
"
	done
	logger_trace "$fun: retval to return: $retval"
	echo "$retval"
}
