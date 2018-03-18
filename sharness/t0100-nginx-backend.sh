#!/bin/sh

test_description="Test the generation of the backend string generation"

wd=$(pwd)

. $wd/lib/sharness/sharness.sh
. $wd/../lib/_nginx_cfg_backend.sh

expected="server backend1 max_fails=3 fail_timeout=5s max_conns=100;"
test_expect_success "Single backend" '
	export PROXY_BACKENDS="backend1"
	export PROXY_TUNING_UPSTREAM_MAX_CONNS=100
	test "$expected" = "$(nginx_cfg_backend_string_core)"
'

expected="server backend1 max_fails=3 fail_timeout=5s max_conns=50;
server backend2 max_fails=3 fail_timeout=5s max_conns=50;"
test_expect_success "Two backends" '
	export PROXY_BACKENDS="backend1 backend2"
	export PROXY_TUNING_UPSTREAM_MAX_CONNS=50
	test "$expected" = "$(nginx_cfg_backend_string_core)"
'

expected="server backend1 max_fails=3 fail_timeout=5s max_conns=50;
server backend2 max_fails=3 fail_timeout=5s max_conns=50;
server backend3 max_fails=3 fail_timeout=5s max_conns=50;"
test_expect_success "Three backends" '
	export PROXY_BACKENDS="backend1 backend2 backend3"
	export PROXY_TUNING_UPSTREAM_MAX_CONNS=50
	test "$expected" = "$(nginx_cfg_backend_string_core)"
'

test_done
