#!/bin/sh

# Global variables created by the script
env_vars="PROXY_MODE\
	PROXY_DOMAIN\
	PROXY_HTTP_PORT\
	PROXY_HTTPS_PORT\
	PROXY_BACKENDS\
	PROXY_CERTBOT_MAIL\
	PROXY_AUTH_USER\
	PROXY_AUTH_PASSWORD\
	PROXY_TUNING_WORKER_CONNECTIONS\
	PROXY_TUNING_UPSTREAM_MAX_CONNS"
cert_method=
le_path=
le_privkey=
le_fullchain=
env_names=
