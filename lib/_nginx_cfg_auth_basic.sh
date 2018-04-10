#!/bin/sh

authBasicFile="/etc/nginx/conf.d/auth_basic.inc"

# Creates the content to put in the auth basic file
# Parameters:
# $1 user
# $2 password
nginx_cfg_auth_basic_file_content(){
	local user=$1
	local password=$2
	local retval=""
	if [ ! -z $user ] && [ ! -z $password ]
	then
		local retval="$user:{PLAIN}$password"
	fi
	echo "$retval"
}

# Creates the file with the auth basic user/password
# Parameters:
# $1: user
# $2: password
nginx_cfg_auth_basic_file(){
	local user=$1
	local password=$2
	if [ ! -z $user ] && [ ! -z $password ]
	then
		basicContent=$(nginx_cfg_auth_basic_file_content $user $password)
		if [ ! $basicContent = "" ]
		then
			echo "$basicContent" > $authBasicFile
		fi
	fi
}

# Return the basic section and create the basic auth file
# Parameters:
# $1: user
# $2: password
# $3: domain/realm
nginx_cfg_auth_basic() {
	local user=$1
	local password=$2
	local realm=$3
	retval=""
	if [ ! -z $user ] && [ ! -z $password ] && [ ! -z $realm ]
	then
		nginx_cfg_auth_basic_file $user $password
		retval="  auth_basic \"$realm\";
  auth_basic_user_file ${authBasicFile};
"
	fi
	echo "$retval"
}
