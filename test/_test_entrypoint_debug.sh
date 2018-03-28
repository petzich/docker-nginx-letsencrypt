#! /bin/sh

wd="$(dirname $0)"
. $wd/../lib/_entrypoint_debug.sh

# Test if no prefix is given
testEmptyPrefix() {
	echo_prefix=""
	expected="hello"
	actual="$(echo_with_prefix 'hello')"
	assertEquals $expected $actual
}

# Test the prefix is prepended (with one space
testWithPrefix() {
	echo_prefix="test-prefix:"
	expected="test-prefix: hello"
	actual="$(echo_with_prefix 'hello')"
	assertEquals "$expected" "$actual"
}

# Test debug output with loglevel "testlevel"
testWithTestlevel() {
	echo_prefix="test-prefix:"
	expected="test-prefix: [testlevel] hello"
	actual="$(echo_with_loglevel testlevel 'hello')"
	assertEquals "$expected" "$actual"
}

testDefaultLoglevel3(){
	prepare_loglevel
	assertEquals $ENTRYPOINT_LOGLEVEL 3
}

testErrorMessage(){
	echo_prefix="test-prefix:"
	expected="test-prefix: [ERROR] hello"
	actual="$(echo_error 'hello')"
	assertEquals "$expected" "$actual"
}

testWarnMessage(){
	echo_prefix="test-prefix:"
	expected="test-prefix: [WARNING] hello"
	actual="$(echo_warn 'hello')"
	assertEquals "$expected" "$actual"
}

testInfoMessage(){
	echo_prefix="test-prefix:"
	expected="test-prefix: [info] hello"
	actual="$(echo_info 'hello')"
	assertEquals "$expected" "$actual"
}

# Debug level has to be set explicitly to generate an output
testDebugMessage(){
	echo_prefix="test-prefix:"
	expected=""
	actual="$(echo_debug 'hello')"
	assertEquals "$expected" "$actual"
	export ENTRYPOINT_LOGLEVEL=4
	expected="test-prefix: [debug] hello"
	actual="$(echo_debug 'hello')"
	assertEquals "$expected" "$actual"
}

. $wd/shunit2/shunit2
