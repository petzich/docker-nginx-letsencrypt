petzi/nginx-letsencrypt
=======================

A docker image combining nginx as a reverse proxy and letsencrypt.

Volumes
-------

The following directory is defined as a volume and should be mounted into a volume container to persist the letsencrypt setting:

`/etc/letsencrypt`

Variables
---------

The following environment variables are defined:

* `PROXY_MODE` (optional): if set to 'dev', the container creates a self-signed certificate. Not for production mode. If set to 'dev' `PROXY_CERTBOT_MAIL` does not have to be set.
* `PROXY_DOMAIN`: The domain used for the certificate.
* `PROXY_HTTP_PORT` (optional): The port for the HTTP server
* `PROXY_HTTPS_PORT` (optional): The port for the HTTPS server
* `PROXY_CERTBOT_MAIL`: The email address for the certbot. Optional if running in dev mode.
* `PROXY_BACKENDS`: A space-separated list of the backend hostnames to balance the requests to.
* `PROXY_STATIC_DIRS` (optional): a space-separated list of directory names you would like nginx to serve statically.
* `PROXY_AUTH_USER` (optional): username to protect access to HTTPS. HTTP is left open and redirects to the HTTPS url.
* `PROXY_AUTH_PASSWORD`: password for the user. Required if PROXY\_AUTH\_USER is set.
* `PROXY_TUNING_UPSTREAM_MAX_CONNS`: maximum number of concurrent connections to an upstream server (per server). Default value: 0 (no limits)
* `PROXY_TUNING_WORKER_CONNECTIONS`: maximum number of worker connections to use. Default: 512.
* `ENTRYPOINT_LOGLEVEL`: 1=error, 2=warning, 3=info [default if not set], 4=debug

PROXY\_STATIC\_DIRS
-------------------
PROXY\_STATIC\_DIRS maps locations to filepaths in the container. The format is:

`<map>,<path>[ <map>,<path>]*`

An example: `css,/var/www/html images,/` will map:
* `/css/` onto `/var/www/html/css`
* `/images/` onto `/images/`

Contributing
------------

There are some development tools set up. Install vagrant and run:

```
vagrant up
vagrant ssh
make
make run
```
With this you can start the test configuration from the directory `/test` in the repository. Interesting URLs:
`http://localhost:2080/`
`https://localhost:2443/`
`https://localhost:2443/static`
`https://localhost:2443/nothing`

If you find any bug, a pull request is welcome. You can also submit an issue, but it will take longer to process.
