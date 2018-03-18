#!/bin/sh

test_description="Test the generation of the backend string generation"

wd=$(pwd)

. $wd/lib/sharness/sharness.sh
. $wd/../lib/_nginx_cfg_backend.sh

expected="server backend1 max_fails=3 fail_timeout=5s max_conns=100;"
test_expect_success "Single backend" '
	export PROXY_BACKENDS="backend1"
	export PROXY_TUNING_UPSTREAM_MAX_CONNS=100
	echo $expected >e1 &&
	echo $(nginx_cfg_backend_string_core) >a1 &&
	test_cmp e1 a1
'

expected="server backend1 max_fails=3 fail_timeout=5s max_conns=50;
server backend2 max_fails=3 fail_timeout=5s max_conns=50;"
test_expect_success "Two backends" '
	export PROXY_BACKENDS="backend1 backend2"
	export PROXY_TUNING_UPSTREAM_MAX_CONNS=50
	echo $expected >e2 &&
	echo $(nginx_cfg_backend_string_core) >a2 &&
	test_cmp e2 a2
'

expected="server backend1 max_fails=3 fail_timeout=5s max_conns=50;
server backend2 max_fails=3 fail_timeout=5s max_conns=50;
server backend3 max_fails=3 fail_timeout=5s max_conns=50;"
test_expect_success "Three backends" '
	export PROXY_BACKENDS="backend1 backend2 backend3"
	export PROXY_TUNING_UPSTREAM_MAX_CONNS=50
	echo $expected >e3 &&
	echo $(nginx_cfg_backend_string_core) >a3 &&
	test_cmp e3 a3
'

export expected="upstream backend_server {
ip_hash;
server backend1 max_fails=3 fail_timeout=5s max_conns=50;
server backend2 max_fails=3 fail_timeout=5s max_conns=50;
server backend3 max_fails=3 fail_timeout=5s max_conns=50;
}"
test_expect_success "Complete string" '
	export PROXY_BACKENDS="backend1 backend2 backend3"
	export PROXY_TUNING_UPSTREAM_MAX_CONNS=50
	echo $expected >e-complete &&
	echo $(nginx_cfg_backend_string) >a-complete &&
	test_cmp e-complete a-complete
'


test_done
