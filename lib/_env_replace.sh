#!/bin/sh

# Replace environment variables in a file
# This is a public API
# Parameters:
# 1. Input filename
# 2. Output filename
# 3. Whitelist of environment variables. Use quoting.
env_replace_in_file() {
	inFile=$1
	outFile=$2
	varlist=$3
	logger_debug "varlist: $varlist"
	if [ -f $inFile ]
	then
		es_vars=$(env_prepare_variable_list "$varlist")
		logger_debug "es_vars: $es_vars"
		envsubst "${es_vars}" < $inFile >$outFile
	else
		echo "ERROR: inFile $inFile not found"
	fi
}

# Process the variable list
# The input list is a space-separated list of variable names
# The output is a list of variables in "shell"-style for envsubst
# The output is also processed by cleaning the variable names
# Example input: "a1 a2 a3"
# Example output: "${a1} ${a2} ${a3}"
env_prepare_variable_list() {
	local invars=$1
	for v in ${invars}
	do
		local var_clean=$(env_name_cleanup $v)
		outvars_cleaned="${outvars_cleaned} ${var_clean}"
	done
	export $outvars_cleaned
	for outvar in ${outvars_cleaned}
	do
		outvars="${outvars} \${${outvar}}"
	done
	# xargs is used to trim whitespace
	echo "$outvars" | xargs
}

# Restrict the name of environment variables to [a-zA-Z0-9_]
# Parameters:
# 1. environment variable name
env_name_cleanup(){
	local retval=$(echo "$1" | sed -e 's/[^a-zA-Z0-9_]//g')
	echo "$retval"
}

# Escape special characters for regex processing
# Parameters:
# $1: the string (quote)
escape_regex(){
	local input=$1
	local retval=$(echo "$input" | sed -e 's/#/\\#/g')
	echo "$retval"
}
