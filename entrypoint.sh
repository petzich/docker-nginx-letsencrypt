#!/bin/sh

echo "entrypoint.sh: Starting"
echo "PROXY_MODE: $PROXY_MODE"
echo "PROXY_DOMAIN: $PROXY_DOMAIN"
echo "PROXY_HTTP_PORT: $PROXY_HTTP_PORT"
echo "PROXY_HTTPS_PORT: $PROXY_HTTPS_PORT"
echo "PROXY_BACKEND: $PROXY_BACKEND"
echo "PROXY_CERTBOT_MAIL: $PROXY_CERTBOT_MAIL"
echo "PROXY_AUTH_USER: $PROXY_AUTH_USER"
if [ -z $PROXY_AUTH_PASSWORD ]
then
	pap_state="not set"
else
	pap_state="set"
fi
echo "PROXY_AUTH_PASSWORD is $pap_state"
echo "command to run: $@"

# If PROXY_MODE is dev, then a self-signed certificate will be issued
# to the domain localhost.
if [ ! -z ${PROXY_MODE} ] && [ ${PROXY_MODE} = "dev" ]
then
    echo "WARN: Running in dev mode. Will use self-signed certificates."
    echo "WARN: Not recommended for integration and production setup."
    echo "WARN: Only localhost will be used as a host name."
    DEV_PROXY_DIR="/etc/letsencrypt/live/${PROXY_DOMAIN}"
    DEV_PROXY_PRIVKEY="${DEV_PROXY_DIR}/privkey.pem"
    DEV_PROXY_FULLCHAIN="${DEV_PROXY_DIR}/fullchain.pem"
    DEV_SUBJECT="/C=CH/ST=BE/L=Berne/O=ExampleOrg/OU=Org/CN=localhost"
else
    if [ -z ${PROXY_CERTBOT_MAIL} ]
    then
        echo "FAIL: PROXY_CERTBOT_MAIL is not set. It is required for letsencrypt"
        exit 1
    fi
fi

# PROXY_DOMAIN must be set, or there is no use in starting the proxy.
# In PROXY_MODE==dev, this value is overriden to "localhost".
if [ -z ${PROXY_DOMAIN} ]
then
    echo "FAIL: PROXY_DOMAIN is not set"
    exit 1
fi

# PROXY_BACKEND should be set.
if [ -z ${PROXY_BACKEND} ]
then
    echo "WARN: PROXY_BACKEND is not set."
    echo "WARN: The hostname 'localhost' will be used."
    echo "WARN: This will most likely cause errors."
    PROXY_BACKEND="localhost"
fi

if [ -z $PROXY_HTTP_PORT ]; then
	PROXY_HTTP_PORT="80"
fi
if [ -z $PROXY_HTTPS_PORT ]; then
	PROXY_HTTPS_PORT="443"
fi

echo "entrypoint.sh: generating acme-challenge directory"
mkdir -p /var/www/html/.well-known/acme-challenge
chown -R nginx:nginx /var/www/html/.well-known

# Set daemon off in the main configuration file.
# On restart, the directive should not be added a second time
echo "Set daemon mode off"
if [ `grep -c "daemon off" /etc/nginx/nginx.conf` -lt 1 ]
then
	sed -i -e '1idaemon off;\' /etc/nginx/nginx.conf
fi

nginx_conf="/etc/nginx/nginx.conf"

# Set basic_auth in the global http section
if [ ! -z ${PROXY_AUTH_USER} ]
then
	echo "Setting HTTP basic protection (user: $PROXY_AUTH_USER)"
	# Create the file first
	echo "$PROXY_AUTH_USER:{PLAIN}$PROXY_AUTH_PASSWORD" > /etc/nginx/conf.d/auth_basic.inc
	# Then configure auth_basic in the HTTP section
	if [ `grep -c "auth_basic" $nginx_conf` -lt 1 ]
	then
		# First time
		sed -i '/^http/a \auth_basic "test";' $nginx_conf
		sed -i '/^auth_basic\ /a \auth_basic_user_file /etc/nginx/conf.d/auth_basic.inc;' $nginx_conf
	else
		sed -i 's/^auth_basic.*$\ /auth_basic "test";/' $nginx_conf
		sed -i 's/^auth_basic_user_file.*$\ /auth_basic_user_file /etc/nginx/conf.d/auth_basic.inc;/' $nginx_conf
	fi
fi

echo "entrypoint.sh: generating configuration files"
cat /etc/nginx/conf.d/default_backend.conf.orig | sed -E "s/localhost/${PROXY_BACKEND}/" > /etc/nginx/conf.d/default_backend.conf
cat /etc/nginx/conf.d/default.conf.orig | sed -E "s/localhost/${PROXY_DOMAIN}/" > /etc/nginx/conf.d/default.conf
sed -i "s/^.*listen.*$/    listen ${PROXY_HTTP_PORT};/g" /etc/nginx/conf.d/default.conf

echo "entrypoint.sh: starting nginx in background for certificate generation"
exec nginx &
sleep 1

# Generate a certificate.
# In PROXY_MODE dev generate self-signed using openssl
# In any other mode, generate using certbot
if [ ! -z ${PROXY_MODE} ] && [ ${PROXY_MODE} = "dev" ]
then
    mkdir -p ${DEV_PROXY_DIR}
    if [ -f ${DEV_PROXY_PRIVKEY} ]
    then
        echo "INFO: private key already exists, not overwriting. path:"
        echo "INFO: ${DEV_PROXY_PRIVKEY}"
    else
        openssl req -subj ${DEV_SUBJECT} -x509 -sha256 -newkey rsa:1024 -nodes -keyout ${DEV_PROXY_PRIVKEY} -out ${DEV_PROXY_FULLCHAIN} -days 365
    fi
elif [ -f "/etc/letsencrypt/live/${PROXY_DOMAIN}/fullchain.pem" ]
then
    certbot renew
else
    # certbot is run with the following options:
    # certonly (installing in nginx is not yet supported)
    # -n        = non-interactive (this is a script, after all)
    # --webroot = webroot method to /var/www/html
    # -d        = domain is passed as ENV variable
    # --agree-tos   = agree to terms of service (non-interactive)
    # -m            = mail address for letsencrypt account
    # --keep        = do not replace existing certificate, unless expiry is close
    certbot certonly -n --webroot -w /var/www/html -d ${PROXY_DOMAIN} --agree-tos -m ${PROXY_CERTBOT_MAIL} --keep
fi

killall nginx
sleep 1

cat /etc/nginx/conf.d/default_ssl.conf.orig | sed -E "s/localhost/${PROXY_DOMAIN}/" > /etc/nginx/conf.d/default_ssl.conf
sed -i "s/^.*listen.*$/    listen ${PROXY_HTTPS_PORT};/g" /etc/nginx/conf.d/default_ssl.conf

# Redirect to https port
sed -i "s/^.*return.*$/        return 301 https:\/\/\$server_name:${PROXY_HTTPS_PORT}\$request_uri;/" /etc/nginx/conf.d/default.conf

# Create the entries for static files
stat="/etc/nginx/conf.d/default_static_dirs.conf.inc"
echo "" > $stat
for i in $PROXY_STATIC_DIRS
do
	location=`echo $i | awk -F"," '{print $1}'`
	directory=`echo $i | awk -F"," '{print $2}'`
    echo "creating static entry: $location -> $directory"
    echo "location /$location/ { root $directory; }" >> $stat
done

if [ -d /extraconf ]
then
	cp /extraconf/* /etc/nginx/conf.d/
fi

if [ -d /extrahtml ]
then
	cp -a /extrahtml/* /var/www/html/
fi

# And last but not least the most important action: call nginx.
echo "Starting nginx with $@"
exec "$@"
