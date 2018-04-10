#! /bin/sh

. ${libdir}/_nginx_cfg_auth_basic.sh
authBasicFile="/etc/nginx/conf.d/auth_basic.inc"

setUp(){
	if [ -f $authBasicFile ]; then rm $authBasicFile; fi
}

testAuthBasicFileContent() {
	expected="testUser:{PLAIN}testPassword!äöü"
	actual=$(nginx_cfg_auth_basic_file_content "testUser" "testPassword!äöü")
	assertEquals "$expected" "$actual"
}

testAuthBasicFileContentMissingPassword() {
	expected=""
	actual=$(nginx_cfg_auth_basic_file_content "testUser")
	assertEquals "$expected" "$actual"
}

testAuthBasicFileContentMissingParams() {
	expected=""
	actual=$(nginx_cfg_auth_basic_file_content)
	assertEquals "$expected" "$actual"
}

testAuthBasicFile() {
	expected="testUser:{PLAIN}testPassword!äöü"
	$(nginx_cfg_auth_basic_file "testUser" "testPassword!äöü")
	assertTrue "[ -f $authBasicFile ]" 
	actual=$(cat $authBasicFile)
	assertEquals "$expected" "$actual"
}

testAuthBasicFileEmpty() {
	$(nginx_cfg_auth_basic_file "testUser")
	assertTrue "[ ! -f $authBasicFile ]" 
}

# Test the configuration of auth_basic
testAuthBasicConfig(){
	expected="  auth_basic \"test.my.example.org\";
  auth_basic_user_file /etc/nginx/conf.d/auth_basic.inc;"
	actual=$(nginx_cfg_auth_basic "testUser" "testPassword!äöü" "test.my.example.org")
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

