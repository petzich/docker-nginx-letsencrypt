#!/bin/sh

# Set some variables
acme_challenge_dir=/var/www/html/.well-known/acme-challenge

# Create the directory for acme challenges
create_acme_challenge_dir(){
	logger_debug "Creating acme-challenge directory: $acme_challenge_dir"
	mkdir -p $acme_challenge_dir
	chown -R nginx:nginx $acme_challenge_dir/../
}
