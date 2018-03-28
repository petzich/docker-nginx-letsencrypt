#!/bin/sh

# Script should echo all output in the same manner
echo_with_prefix(){
	echo "$echo_prefix $1"
}

echo_with_loglevel(){
	echo_loglevel="[$1]"
	shift;
	echo_message="$@"
	echo_with_prefix "$echo_loglevel $echo_message"
}

# Use this level if the script has to exit with an error
echo_error(){
	echo_with_loglevel "ERROR" $1
}

# Use this level if a user should configure an environment variable,
# but hasn't done so. Or if setting an environment variable to a certain
# value has unexpected consequences for the user.
echo_warn(){
	if [ "$ENTRYPOINT_LOGLEVEL" -ge 2 ]
	then
		echo_with_loglevel "WARNING" $1
	fi
}

# Use this level to output relevant information on user configuration a
# derived image.
echo_info(){
	if [ "$ENTRYPOINT_LOGLEVEL" -ge 3 ]
	then
		echo_with_loglevel "info" $1
	fi
}

# Use this level to output internal information on this script
echo_debug(){
	if [ "$ENTRYPOINT_LOGLEVEL" -ge 4 ]
	then
		echo_with_loglevel "debug" $1
	fi
}

# Prepare the loglevel
prepare_loglevel(){
	if [ -z ${ENTRYPOINT_LOGLEVEL} ]
	then
		ENTRYPOINT_LOGLEVEL=3
	fi
}
