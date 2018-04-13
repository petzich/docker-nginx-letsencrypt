#! /bin/sh

. ${libdir}/_nginx_cfg_static.sh
. ${testdir}/_init_log_setup.sh

testStaticSingleLine(){
	local location="hello"
	local directory="/var/www"
	expected="location /hello/ { root /var/www; }"
	actual=$(nginx_cfg_static_single_line $location $directory)
	assertEquals "$expected" "$actual"
	local location="toplevel"
	local directory="/"
	expected="location /toplevel/ { root /; }"
	actual=$(nginx_cfg_static_single_line $location $directory)
	assertEquals "$expected" "$actual"
}

testStaticConfigOneEntry(){
	local input="css,/var/www/html"
	local expected="location /css/ { root /var/www/html; }"
	local actual=$(nginx_cfg_static_string "$input")
	assertEquals "$expected" "$actual"
}

testStaticConfigManyEntries(){
	local input="css,/var/www/html toplevel,/"
	local expected="location /css/ { root /var/www/html; }
location /toplevel/ { root /; }"
	local actual=$(nginx_cfg_static_string "$input")
	assertEquals "$expected" "$actual"
}

. ${extlibdir}/shunit2/shunit2
