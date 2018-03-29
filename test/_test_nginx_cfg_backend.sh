#! /bin/sh

. ${libdir}/_nginx_cfg_backend.sh

# When only one backend is given
testSingleBackend(){
	expected="server backend1.example.org max_fails=3 fail_timeout=5s max_conns=100;"
	export PROXY_TUNING_UPSTREAM_MAX_CONNS=100
	actual=$(nginx_cfg_single_backend_line "backend1.example.org")
	assertEquals "$expected" "$actual"
}

# Test generation of whole backend string
testWholeBackendString(){
	expected="upstream backend_server {
  ip_hash;
  server backend1 max_fails=3 fail_timeout=5s max_conns=50;
  server backend2 max_fails=3 fail_timeout=5s max_conns=50;
  server backend3 max_fails=3 fail_timeout=5s max_conns=50;
}"
	export PROXY_BACKENDS="backend1 backend2 backend3"
        export PROXY_TUNING_UPSTREAM_MAX_CONNS=50
	actual=$(nginx_cfg_backend_string)
	assertEquals "$expected" "$actual"
}

. ${extlibdir}/shunit2/shunit2
