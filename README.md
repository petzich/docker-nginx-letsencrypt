# petzi/nginx-letsencrypt

A docker image combining nginx as a reverse proxy and letsencrypt.

## Volumes

The following directory is defined as a volume and should be mounted into a volume container to persist the letsencrypt setting:

`/etc/letsencrypt`

## Variables

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
* `ENTRYPOINT_LOGLEVEL`: ERROR, WARN, INFO, DEBUG. Default: INFO

### PROXY\_STATIC\_DIRS

PROXY\_STATIC\_DIRS maps locations to filepaths in the container. The format is:

`<map>,<path>[ <map>,<path>]*`

An example: `css,/var/www/html images,/` will map:
* `/css/` onto `/var/www/html/css`
* `/images/` onto `/images/`

## Online reconfiguration

There are two scripts to help you execute operations in a running container.

### cert-renew.sh

Lets you renew the certificate(s).

### backend-reconfigure.sh

Lets you temporarily disable or enable certain backends. The setting is *not* persisted on container restarts.

```
# Enable only backend1.example.org, disable all other backends
./backend-reconfigure.sh --enable backend1.example.org
# Disable only backend1.example.org, enable all other backends
./backend-reconfigure.sh --disable backend1.example.org
# Enable all backends (which is what happens by default when starting the container)
./backend-reconfigure.sh --all
```

## Extending

You can extend the image with your own configuration. Make your derived docker image by using

`FROM petzi/nginx-letsencrypt:x.y.z`

### /extraconf processing

WARNING: The processing of these files might change until the 1.0 release.

You can add files in a top-level-directory `/extraconf`. Those files will be processed by the entrypoint script and added to the nginx configuration. Example filenames:

`http_compression.conf`
`ssl_custom_rewrites.conf.inc`
`stream_tcp_socket.conf.orig`

#### File extension processing

0. All files in `/extraconf` will be placed into the directory `/etc/nginx/conf.d`
0. `http_*.conf` will be included in the `http` section of the main configuration
0. `stream_*.conf` will be included in the `stream` section of the main configuration
0. `ssl_*.conf.inc` will be included in the https configuration

#### Processing of files with environment variables

You can also create some files with an extension `*.orig`. Those files will be processed to replace environment variables in the configuration file and produce the corresponding file.

0. `stream_*.conf.orig`: Replace environment variables and output as `stream_*.conf`
0. `ssl_*.conf.inc.orig`: Replace environment variables and output as `ssl_*.conf.inc`

You should place environment variables inside those files using the dollar sign and curly braces:
`${MY_ENV_VAR}`. This processing is also done internally for some files in this docker image. Use the file `conf/http_default_ssl.conf.orig` as an example.

# Example Usage

There is the directory `example` whith an example usage. It contains a `frontend` (proxy) as well as a `backend` (with an example html page).

To use it:

1. Install docker (CE) on your computer
1. `cd example`
1. `make run`

Interesting URLs:

```
http://localhost:2080/ (will redirect to localhost:2443)
https://localhost:2443/ (requires authentication test:password)
```

# Contributing

Pull requests and issues are welcome. As a rule of thumb, pull requests will be processed faster than issues.

## Get started

```
git clone --recurse-submodules git@github.com:petzich/docker-nginx-letsencrypt.git
```

1. Install docker (CE) on your local machine.
1. run `make`
1. run `make test`
