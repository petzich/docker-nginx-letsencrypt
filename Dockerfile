FROM nginx:1.13-alpine

# certbot from letsencrypt
# gettext for envsubst
# openssl for self-signed certificates in dev mode
RUN apk add --no-cache \
 certbot \
 gettext \
 openssl

VOLUME /etc/letsencrypt/
ENTRYPOINT ["/entrypoint.sh"]
CMD ["nginx"]
RUN rm /etc/nginx/conf.d/default.conf

COPY entrypoint.sh /entrypoint.sh
RUN chmod u+x /entrypoint.sh

COPY nginx.conf /etc/nginx/
COPY conf/* /etc/nginx/conf.d/
