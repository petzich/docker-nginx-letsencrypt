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
	local fun="certificate_exists()"
	local privkey=$1
	local pubkey=$2
	logger_trace "$fun: checking existence of $privkey and $pubkey"
	if [ -f $privkey ] && [ -f $pubkey ]
	then
		logger_trace "$fun: Both files exist"
		return 0
	elif [ -f $privkey ]
	then
		logger_error "$fun: Only the private key exists. The public key is missing. This should not normally happen."
		logger_error "$fun: (Present) private key: $privkey"
		logger_error "$fun: (Missing) public key: $pubkey"
		return 1
	elif [ -f $pubkey ]
	then
		logger_error "$fun: Only the public key exists. The private key is missing. This should not normally happen."
		logger_error "$fun: (Missing) private key: $privkey"
		logger_error "$fun: (Present) public key: $pubkey"
		return 2
	else
		logger_trace "$fun: No file exists"
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
	local fun="certificate_create()"
	local privkey=$1
	local pubkey=$2
	local method=$3
	local certbot_domain=$4
	local certbot_mail=$5
	certificate_exists $privkey $pubkey
	local retval=$?
	if [ $retval -le 2 ]
	then
		logger_error "$fun: Certificate already exists, not overwriting"
		return 1
	fi
		# Creating directories for certificate
		dirpriv=$(dirname $privkey)
		dirpub=$(dirname $pubkey)
		mkdir -p $dirpriv
		mkdir -p $dirpub
		if [ "$method" = "selfsigned" ]
		then
			logger_debug "$fun: Creating self-signed certificate"
			openssl req -subj $dev_subject -x509 -sha256 -newkey rsa:1024 -nodes -keyout $privkey -out $pubkey -days 365
			return 0
		elif [ "$method" = "certbot" ]
		then
			if [ -z ${certbot_domain} ] || [ -z ${certbot_mail} ]
			then
				logger_error "$fun: variable certbot_domain or certbot_mail are not set"
				return 1
			else
				logger_debug "$fun: Creating letsencrypt certificate. Domain: $certbot_domain. Mail: $certbot_mail."
				certbot certonly -n --webroot -w /var/www/html -d $certbot_domain --agree-tos -m $certbot_mail --keep
				return 0
			fi
		else
			logger_error "$fun: Method was not 'selfsigned' or 'certbot'"
			return 1
		fi
}

# Update a certificate
# $1: filename of private key
# $2: filename of public key
# $3: method (either 'selfsigned' or 'certbot')
certificate_renew(){
	local fun="certificate_renew()"
	local privkey=$1
	local pubkey=$2
	local method=$3
	logger_debug "$fun: renewing certificate. privkey: $privkey, pubkey: $pubkey, method: $method"
	# Check if certificate exists, if not refuse renewal
	certificate_exists $privkey $pubkey
	local retval=$?
	if [ ! $retval -eq 0 ]
	then
		logger_error "$fun: certificate does not exist, will not renew"
		return 1
	fi
	if [ "$method" = "selfsigned" ]
	then
		logger_debug "$fun: renewing self-signed certificate"
		openssl req -subj $dev_subject -x509 -sha256 -newkey rsa:1024 -nodes -keyout $privkey -out $pubkey -days 365
		return 0
	elif [ "$method" = "certbot" ]
	then
		logger_debug "$fun: renewing certbot certificate"
		certbot renew
		return 0
	else
		logger_error "$fun: please provide either method 'selfsigned' or 'certbot'"
		return 1
	fi
}
