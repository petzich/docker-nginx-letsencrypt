#!/bin/sh

test_description="Test the generation of the backend string generation"

wd=$(pwd)

. $wd/lib/sharness/sharness.sh
. $wd/../lib/_entrypoint_debug.sh

test_expect_success "echo_with_prefix empty" '
	echo_prefix=""
	echo "hello" >e-echo-empty &&
	echo $(echo_with_prefix "hello") >a-echo-empty &&
	test_cmp e-echo-empty a-echo-empty
'

test_expect_success "echo_with_prefix test-prefix" '
	echo_prefix="test-prefix:"
	echo "test-prefix: hello" >e-echo-empty &&
	echo $(echo_with_prefix "hello") >a-echo-empty &&
	test_cmp e-echo-empty a-echo-empty
'

test_expect_success "echo_with_loglevel testlevel" '
	echo_prefix="test-prefix:"
	echo "test-prefix: [testlevel] hello" >e-echo-empty &&
	echo $(echo_with_loglevel testlevel "hello") >a-echo-empty &&
	test_cmp e-echo-empty a-echo-empty
'

test_expect_success "prepare_loglevel empty" '
	prepare_loglevel &&
	test $ENTRYPOINT_LOGLEVEL = 3
'

test_expect_success "echo_error somemessage" '
	echo_prefix="test-prefix:"
	echo "test-prefix: [ERROR] hello" >e-echo-empty &&
	echo $(echo_error "hello") >a-echo-empty &&
	test_cmp e-echo-empty a-echo-empty
'

test_expect_success "echo_warning somemessage" '
	echo_prefix="test-prefix:"
	echo "test-prefix: [WARNING] hello" >e-echo-empty &&
	echo $(echo_warn "hello") >a-echo-empty &&
	test_cmp e-echo-empty a-echo-empty
'

test_expect_success "echo_info somemessage" '
	echo_prefix="test-prefix:"
	echo "test-prefix: [info] hello" >e-echo-empty &&
	echo $(echo_info "hello") >a-echo-empty &&
	test_cmp e-echo-empty a-echo-empty
'

test_expect_success "echo_debug implicit_level" '
	echo_prefix="test-prefix:"
	echo "" >e-echo-empty &&
	echo $(echo_debug "hello") >a-echo-empty &&
	test_cmp e-echo-empty a-echo-empty
'

test_expect_success "echo_debug explicit_loglevel" '
	export ENTRYPOINT_LOGLEVEL=4
	$(prepare_loglevel)
	echo_prefix="test-prefix:"
	echo "test-prefix: [debug] hello" >e-echo-empty &&
	echo $(echo_debug "hello") >a-echo-empty &&
	test_cmp e-echo-empty a-echo-empty
'

test_done
