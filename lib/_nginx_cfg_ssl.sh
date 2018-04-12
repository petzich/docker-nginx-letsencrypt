#!/bin/sh

nginx_conf_dir="/etc/nginx/conf.d"
disabled_dir="disabled.d"
nginx_disabled_dir=$nginx_conf_dir/$disabled_dir

# Disable files with SSL configuration
ssl_conf_disable(){
	local fun="ssl_conf_disable()"
	logger_info "Temporarily disabling configuration files with references to certificates."
	mkdir -p $nginx_disabled_dir
	local files_with_cert_refs=$(grep -l "ssl_certificate" ${nginx_conf_dir}/*)
	for f in $files_with_cert_refs
	do
		local filename=$(basename $f)
		local dest_filename=$nginx_disabled_dir/$filename
		logger_debug "$fun: Disabling: $f -> $dest_filename)"
		mv $f $dest_filename
	done
}

# Enable disabled configuration files
ssl_conf_enable(){
	local fun="ssl_conf_enable()"
	logger_info "Re-enabling disabled configuration files."
	local disabled_files_with_cert_refs=$(grep -l "ssl_certificate" ${nginx_disabled_dir}/*)
	for f in $disabled_files_with_cert_refs
	do
		local filename=$(basename $f)
		local dest_filename=$nginx_conf_dir/$filename
		logger_debug "$fun: Enabling: $f -> $dest_filename)"
		mv $f $dest_filename
	done
}
