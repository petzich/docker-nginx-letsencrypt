#! /bin/sh

. ${libdir}/_nginx_cfg_ssl.sh
. ${testdir}/_init_log_setup.sh

nginx_conf_dir="/etc/nginx/conf.d"
disabled_dir="disabled.d"
nginx_disabled_dir=$nginx_conf_dir/$disabled_dir

setUp(){
	mkdir -p $nginx_disabled_dir
}

tearDown(){
	rm -rf $nginx_conf_dir
}

testSslDisable(){
	echo "normal_conf" > "$nginx_conf_dir/normal.conf"
	echo "ssl_certificate" > "$nginx_conf_dir/ssl.conf"
	ssl_conf_disable
	assertTrue " [ -f $nginx_conf_dir/normal.conf ] "
	assertFalse " [ -f $nginx_conf_dir/ssl.conf ] "
	assertFalse " [ -f $nginx_disabled_dir/normal.conf ] "
	assertTrue " [ -f $nginx_disabled_dir/ssl.conf ] "
}

testSslEnabled(){
	echo "normal_conf" > "$nginx_disabled_dir/normal.conf"
	echo "ssl_certificate" > "$nginx_disabled_dir/ssl.conf"
	ssl_conf_enable
	assertFalse " [ -f $nginx_conf_dir/normal.conf ] "
	assertTrue " [ -f $nginx_conf_dir/ssl.conf ] "
	assertTrue " [ -f $nginx_disabled_dir/normal.conf ] "
	assertFalse " [ -f $nginx_disabled_dir/ssl.conf ] "
}

. ${extlibdir}/shunit2/shunit2
