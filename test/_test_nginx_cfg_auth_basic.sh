#! /bin/sh

. ${libdir}/_nginx_cfg_auth_basic.sh
authBasicFile="/etc/nginx/conf.d/auth_basic.inc"

setUp(){
	unset PROXY_DOMAIN
	unset PROXY_AUTH_USER
	unset PROXY_AUTH_PASSWORD
	if [ -f $authBasicFile ]; then rm $authBasicFile; fi
}

testAuthBasicFileContent() {
	export PROXY_AUTH_USER="testUser"
	export PROXY_AUTH_PASSWORD="testPassword!äöü"
	expected="testUser:{PLAIN}testPassword!äöü"
	actual=$(nginx_cfg_auth_basic_file_content)
	assertEquals "$expected" "$actual"
}

testAuthBasicFileContentMissingUser() {
	export PROXY_AUTH_PASSWORD="testPassword!äöü"
	expected=""
	actual=$(nginx_cfg_auth_basic_file_content)
	assertEquals "$expected" "$actual"
}

testAuthBasicFileContentMissingPassword() {
	export PROXY_AUTH_USER="testUser"
	expected=""
	actual=$(nginx_cfg_auth_basic_file_content)
	assertEquals "$expected" "$actual"
}

testAuthBasicFile() {
	export PROXY_AUTH_USER="testUser"
	export PROXY_AUTH_PASSWORD="testPassword!äöü"
	expected="testUser:{PLAIN}testPassword!äöü"
	$(nginx_cfg_auth_basic_file)
	assertTrue "[ -f $authBasicFile ]" 
	actual=$(cat $authBasicFile)
	assertEquals "$expected" "$actual"
}

testAuthBasicFileEmpty() {
	export PROXY_AUTH_USER="testUser"
	$(nginx_cfg_auth_basic_file)
	assertTrue "[ ! -f $authBasicFile ]" 
}

# Test the configuration of auth_basic
testAuthBasicConfig(){
	expected="  auth_basic \"test.my.example.org\";
  auth_basic_user_file /etc/nginx/conf.d/auth_basic.inc;"
  	export PROXY_DOMAIN="test.my.example.org"
	export PROXY_AUTH_USER="testUser"
	export PROXY_AUTH_PASSWORD="testPassword!äöü"
	actual=$(nginx_cfg_auth_basic)
	assertEquals "$expected" "$actual"
	assertTrue "[ -e $authBasicFile ]"
	expected2="testUser:{PLAIN}testPassword!äöü"
	actual2=$(cat $authBasicFile)
	assertEquals "$expected2" "$actual2"
}

# Test the configuration with empty auth_basic
testAuthBasicEmpty(){
	expected=""
	actual=$(nginx_cfg_auth_basic)
	assertEquals "$expected" "$actual"
}

. ${extlibdir}/shunit2/shunit2

