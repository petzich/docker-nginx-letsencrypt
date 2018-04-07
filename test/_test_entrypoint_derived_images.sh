#! /bin/sh

. ${testdir}/_init_log_setup.sh
. ${libdir}/_entrypoint_derived_images.sh

setUp(){
	unset a1
}

testCopyFiles(){
	mkdir /extrahtml
	mkdir -p /var/www/html
	touch /extrahtml/test1.txt
	touch /extrahtml/test2.html
	copy_files /extrahtml /var/www/html
	assertTrue "test1.txt was not copied" 		"[ -f '/var/www/html/test1.txt' ]"
	assertTrue "test2.html was not copied" 		"[ -f '/var/www/html/test2.html' ]"
	mkdir /extraconf
	mkdir -p /etc/nginx/conf.d
	touch /extraconf/test1.conf
	touch /extraconf/test2.conf.inc
	copy_files /extraconf/ /etc/nginx/conf.d/
	assertTrue "test1.conf was not copied" 		"[ -f '/etc/nginx/conf.d/test1.conf' ]"	
	assertTrue "test2.conf.inc was not copied" 	"[ -f '/etc/nginx/conf.d/test2.conf.inc' ]"
}

testFilesReplaceEnv(){
	export a1="one"
	mkdir /tmp/test/
	echo 'Hello $a1 and $b2' > /tmp/test/test1.orig
	files_replace_vars /tmp/test orig "a1"
	assertTrue "test1 was created" "[ -f /tmp/test/test1 ]"
	expected="Hello one and \$b2"
	actual=$(cat /tmp/test/test1)
	assertEquals "$expected" "$actual"
}

. ${extlibdir}/shunit2/shunit2
