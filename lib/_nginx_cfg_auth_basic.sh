#!/bin/sh

authBasicFile="/etc/nginx/conf.d/auth_basic.inc"

# Creates the content to put in the auth basic file
nginx_cfg_auth_basic_file_content(){
	retval=""
	if [ ! -z ${PROXY_AUTH_USER} ] && [ ! -z ${PROXY_AUTH_PASSWORD} ]
	then
		retval="$PROXY_AUTH_USER:{PLAIN}$PROXY_AUTH_PASSWORD"
	fi
	echo "$retval"
}

# Creates the file with the auth basic user/password
nginx_cfg_auth_basic_file(){
	basicContent=$(nginx_cfg_auth_basic_file_content)
	if [ ! $basicContent = "" ]
	then
		echo "$basicContent" > $authBasicFile
	fi
}

nginx_cfg_auth_basic() {
	retval=""
	if [ ! -z ${PROXY_AUTH_USER} ]
	then
		nginx_cfg_auth_basic_file
		retval="  auth_basic \"${PROXY_DOMAIN}\";
  auth_basic_user_file ${authBasicFile};
"
	fi
	echo "$retval"
}
