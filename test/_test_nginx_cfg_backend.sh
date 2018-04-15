#! /bin/sh

. ${testdir}/_init_log_setup.sh
. ${libdir}/_nginx_cfg_backend.sh

# When only one backend is given
testSingleBackend(){
	expected="server backend1.example.org max_fails=3 fail_timeout=5s max_conns=100;"
	actual=$(nginx_cfg_single_backend_line "backend1.example.org" 100)
	assertEquals "$expected" "$actual"
}

testSingleBackendDown(){
	expected="server backend1.example.org max_fails=3 fail_timeout=5s max_conns=100 down;"
	actual=$(nginx_cfg_single_backend_line "backend1.example.org" 100 down)
	assertEquals "$expected" "$actual"
}

testSingleBackendNonsenseCommand(){
	expected="server backend1.example.org max_fails=3 fail_timeout=5s max_conns=100;"
	actual=$(nginx_cfg_single_backend_line "backend1.example.org" 100 disable)
	assertEquals "$expected" "$actual"
}

# "backend1 backend2 backend3" with "enable_backend1"
testBackendEnableMatcherEnableBackend1(){
	local actual=$(nginx_cfg_backend_enable_matcher backend1 enable_backend1)
	assertEquals "" "$actual"
	local actual=$(nginx_cfg_backend_enable_matcher backend2 enable_backend1)
	assertEquals "down" "$actual"
	local actual=$(nginx_cfg_backend_enable_matcher backend3 enable_backend1)
	assertEquals "down" "$actual"
}

# "backend1 backend2 backend3" with "disable_backend2"
testBackendDisableMatcherDisableBackend2(){
	local actual=$(nginx_cfg_backend_enable_matcher backend1 disable_backend2)
	assertEquals "" "$actual"
	local actual=$(nginx_cfg_backend_enable_matcher backend2 disable_backend2)
	assertEquals "down" "$actual"
	local actual=$(nginx_cfg_backend_enable_matcher backend3 disable_backend2)
	assertEquals "" "$actual"
}

# "backend1 backend2 backend3" with "enable_backend4"
# => disables all backends
testBackendDisableMatcherEnableBackend4(){
	local actual=$(nginx_cfg_backend_enable_matcher backend1 enable_backend4)
	assertEquals "down" "$actual"
	local actual=$(nginx_cfg_backend_enable_matcher backend2 enable_backend4)
	assertEquals "down" "$actual"
	local actual=$(nginx_cfg_backend_enable_matcher backend3 enable_backend4)
	assertEquals "down" "$actual"
}

# "backend1 backend2 backend3" with "disable_backend4"
# => enables all backends
testBackendDisableMatcherDisableBackend4(){
	local actual=$(nginx_cfg_backend_enable_matcher backend1 disable_backend4)
	assertEquals "" "$actual"
	local actual=$(nginx_cfg_backend_enable_matcher backend2 disable_backend4)
	assertEquals "" "$actual"
	local actual=$(nginx_cfg_backend_enable_matcher backend3 disable_backend4)
	assertEquals "" "$actual"
}

# Test generation of whole backend string
testBackendString(){
	expected="upstream backend_server {
  ip_hash;
  server backend1 max_fails=3 fail_timeout=5s max_conns=50;
  server backend2 max_fails=3 fail_timeout=5s max_conns=50;
  server backend3 max_fails=3 fail_timeout=5s max_conns=50;
}"
	actual=$(nginx_cfg_backend_string "backend1 backend2 backend3" 50)
	assertEquals "$expected" "$actual"
}

testBackendStringDisable2(){
	expected="upstream backend_server {
  ip_hash;
  server backend1.example.org max_fails=3 fail_timeout=5s max_conns=50;
  server backend2.example.org max_fails=3 fail_timeout=5s max_conns=50 down;
  server backend3.example.org max_fails=3 fail_timeout=5s max_conns=50;
}"
	actual=$(nginx_cfg_backend_string "backend1.example.org backend2.example.org backend3.example.org" 50 disable_backend2.example.org)
	assertEquals "$expected" "$actual"
}

testBackendStringEnable2(){
	expected="upstream backend_server {
  ip_hash;
  server backend1.example.org max_fails=3 fail_timeout=5s max_conns=50 down;
  server backend2.example.org max_fails=3 fail_timeout=5s max_conns=50;
  server backend3.example.org max_fails=3 fail_timeout=5s max_conns=50 down;
}"
	actual=$(nginx_cfg_backend_string "backend1.example.org backend2.example.org backend3.example.org" 50 enable_backend2.example.org)
	assertEquals "$expected" "$actual"
}

. ${extlibdir}/shunit2/shunit2
