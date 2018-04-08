#! /bin/sh

. ${testdir}/_init_log_setup.sh
. ${libdir}/_cert_functions.sh

privkey=/tmp/test-privkey
pubkey=/tmp/test-pubkey

tearDown(){
	if [ -d $acme_challenge_dir ]; then rmdir -p $acme_challenge_dir; fi
	if [ -f $privkey ]; then rm $privkey; fi
	if [ -f $pubkey ]; then rm $pubkey; fi
}

testAcmeChallengeDir(){
	assertFalse " [ -d $acme_challenge_dir ] "
	create_acme_challenge_dir
	assertTrue " [ -d $acme_challenge_dir ] "
	# TODO: test ownership
}

testCertificateExists(){
	touch $privkey $pubkey
	certificate_exists $privkey $pubkey
	assertEquals 0 $?
}

testCertificateExistsOnlyPrivkey(){
	touch $privkey
	certificate_exists $privkey $pubkey
	assertEquals 1 $?
}

testCertificateExistsOnlyPubkey(){
	touch $pubkey
	certificate_exists $privkey $pubkey
	assertEquals 2 $?
}

testCertificateExistsEmpty(){
	certificate_exists $privkey $pubkey
	assertEquals 255 $?
}

testCertificateCreateSelfsigned(){
	certificate_create $privkey $pubkey selfsigned
	assertTrue " [ -f $privkey ] "
	assertTrue " [ -f $pubkey ] "
	# TODO: test different aspects of certificate
}

testCertificateCreateSelfsignedRefused(){
	touch $privkey
	certificate_create $privkey $pubkey selfsigned
	assertEquals 1 $?
	assertTrue " [ -f $privkey ] "
	assertFalse " [ -f $pubkey ] "
}

# TODO: Test certbot without requiring letsencrypt server

testCertificateCreateNonsenseMethod(){
	certificate_create $privkey $pubkey nonsense
	assertEquals 1 $?
}

testCertificateUpdateSelfSigned(){
	touch $privkey $pubkey
	certificate_renew $privkey $pubkey selfsigned
	assertEquals 0 $?
	assertTrue " [ -f $privkey ] "
	assertTrue " [ -f $pubkey ] "
	# TODO: test filesize > 0
}

testCertificateUpdateSelfSignedRefused(){
	certificate_renew $privkey $pubkey selfsigned
	assertEquals 1 $?
}

# TODO: Test certbot renew without requiring letsencrypt server

testCertificateUpdateNonsenseMethod(){
	touch $privkey $pubkey
	certificate_renew $privkey $pubkey nonsense
	assertEquals 1 $?
}

. ${extlibdir}/shunit2/shunit2
