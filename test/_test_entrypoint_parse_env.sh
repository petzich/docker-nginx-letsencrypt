#! /bin/sh

. ${testdir}/_init_log_setup.sh
. ${libdir}/_entrypoint_parse_env.sh

setUp(){
	env_unset_startswith PROXY_
}

testMinimalProdConfiguration(){
	export PROXY_DOMAIN="example.org"
	export PROXY_CERTBOT_MAIL="test@example.org"
	export PROXY_BACKENDS="backend1"
	prepare_proxy_variables
	assertEquals "prod" "${PROXY_MODE}"
	assertEquals "example.org" "${PROXY_DOMAIN}"
	assertEquals "test@example.org" "${PROXY_CERTBOT_MAIL}"
	assertEquals "backend1" "${PROXY_BACKENDS}"
	assertEquals "80" "${PROXY_HTTP_PORT}"
	assertEquals "443" "${PROXY_HTTPS_PORT}"
	assertEquals "512" "${PROXY_TUNING_WORKER_CONNECTIONS}"
	assertEquals "0" "${PROXY_TUNING_UPSTREAM_MAX_CONNS}"
	assertEquals "/etc/letsencrypt/live/example.org" "$le_path"
	assertEquals "/etc/letsencrypt/live/example.org/privkey.pem" "$le_privkey"
	assertEquals "/etc/letsencrypt/live/example.org/fullchain.pem" "$le_fullchain"
}

testMinimalDevConfiguration(){
	export PROXY_MODE="dev"
	export PROXY_BACKENDS="backend1"
	prepare_proxy_variables
	assertEquals "dev" "${PROXY_MODE}"
	assertEquals "localhost" "${PROXY_DOMAIN}"
	assertEquals "backend1" "${PROXY_BACKENDS}"
	assertEquals "" "${PROXY_CERTBOT_MAIL}"
	assertEquals "80" "${PROXY_HTTP_PORT}"
	assertEquals "443" "${PROXY_HTTPS_PORT}"
	assertEquals "512" "${PROXY_TUNING_WORKER_CONNECTIONS}"
	assertEquals "0" "${PROXY_TUNING_UPSTREAM_MAX_CONNS}"
	assertEquals "/etc/letsencrypt/live/localhost" "$le_path"
	assertEquals "/etc/letsencrypt/live/localhost/privkey.pem" "$le_privkey"
	assertEquals "/etc/letsencrypt/live/localhost/fullchain.pem" "$le_fullchain"
}

# Test error message proxydomain
testErrorProxyDomain(){
	prepare_proxy_variables
	actual=$?
	assertEquals "1" "$actual"
	expected="[FATAL] PROXY_DOMAIN is not set."
	actual=$(tail -n1 $testStdErr)
	assertEquals "$expected" "$actual"
}

# Test error proxyBackends
testErrorProxyBackends(){
	export PROXY_DOMAIN="example.org"
	prepare_proxy_variables
	actual=$?
	assertEquals "1" "$actual"
	expected="[FATAL] PROXY_BACKENDS is not set."
	actual=$(tail -n1 $testStdErr)
	assertEquals "$expected" "$actual"
}

# Test error proxyCertbotMail
testErrorProxyCertbotMail(){
	export PROXY_DOMAIN="example.org"
	export PROXY_BACKENDS="backend1"
	prepare_proxy_variables
	actual=$?
	assertEquals "1" "$actual"
	expected="[FATAL] PROXY_CERTBOT_MAIL is not set. It is required for letsencrypt."
	actual=$(tail -n1 $testStdErr)
	assertEquals "$expected" "$actual"
}

testErrorProxyAuthPassword(){
	export PROXY_DOMAIN="example.org"
	export PROXY_CERTBOT_MAIL="test@example.org"
	export PROXY_BACKENDS="backend1"
	export PROXY_AUTH_USER="user"
	prepare_proxy_variables
	actual=$?
	assertEquals "1" "$actual"
	expected="[FATAL] PROXY_AUTH_USER was set. PROXY_AUTH_PASSWORD must then also be set."
	actual=$(tail -n1 $testStdErr)
	assertEquals "$expected" "$actual"
}

testEnvStartsWith(){
	export TEST_AB="ab"
	export TEST_1="one"
	export TEST_2="two"
	export TEST_CD="cd"
	export TESTNOT="not_matching"
	local expected="TEST_1 TEST_2 TEST_AB TEST_CD"
	local actual=$(env_startswith TEST_)
	assertEquals "$expected" "$actual"
	unset TEST_1 TEST_2 TEST_AB TEST_CD
	local expected=""
	local actual=$(env_startswith TEST_)
	assertEquals "$expected" "$actual"
}

testEnvReplaceNames(){
	export PROXY_DOMAIN="example.org"
	export PROXY_CERTBOT_MAIL="test@example.org"
	export PROXY_BACKENDS="backend1"
	export PROXY_AUTH_USER="user"
	export PROXY_SOMETHING_ELSE="else"
	export NOT_PROXY="not"
	expected="PROXY_AUTH_USER PROXY_BACKENDS PROXY_CERTBOT_MAIL PROXY_DOMAIN PROXY_SOMETHING_ELSE"
	actual=$(prepare_envreplace)
	assertEquals "$expected" "$actual"
}

. ${extlibdir}/shunit2/shunit2
