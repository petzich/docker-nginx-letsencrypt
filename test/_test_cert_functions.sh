#! /bin/sh

. ${testdir}/_init_log_setup.sh
. ${libdir}/_cert_functions.sh

tearDown(){
	rmdir -p $acme_challenge_dir
}

testAcmeChallengeDir(){
	assertFalse " [ -d $acme_challenge_dir ] "
	create_acme_challenge_dir
	assertTrue " [ -d $acme_challenge_dir ] "
	# TODO: test ownership
}

. ${extlibdir}/shunit2/shunit2
