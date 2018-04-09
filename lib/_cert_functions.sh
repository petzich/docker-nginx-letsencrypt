#!/bin/sh

# Set some variables
acme_challenge_dir=/var/www/html/.well-known/acme-challenge
dev_subject="/C=CH/ST=BE/L=Berne/O=ExampleOrg/OU=Org/CN=localhost"

# Create the directory for acme challenges
create_acme_challenge_dir(){
	logger_debug "Creating acme-challenge directory: $acme_challenge_dir"
	mkdir -p $acme_challenge_dir
	chown -R nginx:nginx $acme_challenge_dir/../
}

# Check if certificate exists
# Parameters:
# $1: filename of private key
# $2: filename of public key
certificate_exists(){
	local privkey=$1
	local pubkey=$2
	if [ -f $privkey ] && [ -f $pubkey ]
	then
		return 0
	elif [ -f $privkey ]
	then
		logger_error "Only the private key exists. The public key is missing. This should not normally happen."
		logger_error "(Present) private key: $privkey"
		logger_error "(Missing) public key: $pubkey"
		return 1
	elif [ -f $pubkey ]
	then
		logger_error "Only the public key exists. The private key is missing. This should not normally happen."
		logger_error "(Missing) private key: $privkey"
		logger_error "(Present) public key: $pubkey"
		return 2
	else
		return 255
	fi
}

# Create a certificate. Prameters:
# $1: filename of private key
# $2: filename of public key
# $3: method (either 'selfsigned' or 'certbot')
# $4: certbot-domain-name (only required if using certbot)
# $5: certbot-mail (only required if using certbot)
certificate_create(){
	local privkey=$1
	local pubkey=$2
	local method=$3
	local certbot_domain=$4
	local certbot_mail=$5
	certificate_exists $privkey $pubkey
	if [ "$?" -le "2" ]
	then
		logger_error "Certificate already exists, not overwriting"
		return 1
	fi
		# Creating directories for certificate
		dirpriv=$(dirname $privkey)
		dirpub=$(dirname $pubkey)
		mkdir -p $dirpriv
		mkdir -p $dirpub
		# Check variables for certbot
		if [ "$method" = "selfsigned" ]
		then
			logger_info "Creating self-signed certificate"
			openssl req -subj $dev_subject -x509 -sha256 -newkey rsa:1024 -nodes -keyout $privkey -out $pubkey -days 365
			return 0
		elif [ "$method" = "certbot" ]
		then
			logger_info "Creating letsencrypt certificate"
			certbot certonly -n --webroot -w /var/www/html -d $certbot_domain --agree-tos -m $certbot_mail --keep
			return 0
		else
			logger_error "Method was not 'selfsigned' or 'certbot'"
			return 1
		fi
}

# Update a certificate
# $1: filename of private key
# $2: filename of public key
# $3: method (either 'selfsigned' or 'certbot')
certificate_renew(){
	local privkey=$1
	local pubkey=$2
	local method=$3
	# Check if certificate exists, if not refuse renewal
	certificate_exists $privkey $pubkey
	if [ ! "$?" = "0" ]
	then
		logger_error "Certificate does not exist, will not renew"
		return 1
	fi
	if [ "$method" = "selfsigned" ]
	then
		logger_info "Renewing self-signed certificate"
		certificate_create $privkey $pubkey selfsigned
		return 0
	elif [ "$method" = "certbot" ]
	then
		logger_info "Renewing certbot certificate"
		certbot renew
		return 0
	else
		logger_error "Please provide either method 'selfsigned' or 'certbot'"
		return 1
	fi
}
