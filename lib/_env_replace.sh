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
	if [ -f $inFile ]
	then
		inString=$(cat $inFile)
		logger_trace "inString: $inString"
		outString=$(env_replace_in_string "$inString" "$varlist")
		logger_trace "outString: $outString"
		echo $outString > $outFile
	else
		echo "ERROR: inFile $inFile not found"
	fi
}

# Replace environment variables in a string
# This is a private API
# Parameters
# 1. Input variable (containing a string)
# 2. Whitelist of environment variables. Separated by <space>.
# Output: the string with the variables replaced
env_replace_in_string() {
	local input=$1
	local varlist=$2
	# Initialise output with input
	local output=$input		
	local v
	for v in $varlist
	do
		local var_clean=$(env_name_cleanup $v)
		local input="${output}"
		local val
		eval val="\$$var_clean"
		if [ ! $val = "" ]
		then
			logger_trace "processing variable $var_clean, replacing with value $val" >> /dev/stderr
			# First process curly braces
			local sed_string_curly="s/\\\${$var_clean}/$val/g"
			local output_curly=$(echo $input | sed $sed_string_curly)
			# Then process without curly braces
			local sed_string_short="s/\\\$$var_clean/$val/g"
			local output_short=$(echo $output_curly | sed $sed_string_short)
			local output=$output_short
		else
			logger_trace "ignoring variable $var_clean, as it is not set" >> /dev/stderr
		fi
	done
	echo "$output"
}

# Restrict the name of environment variables to [a-zA-Z0-9_]
# Parameters:
# 1. environment variable name
env_name_cleanup(){
	local retval=$(echo "$1" | sed -e 's/[^a-zA-Z0-9_]//g')
	echo "$retval"
}
