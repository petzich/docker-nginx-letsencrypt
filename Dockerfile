FROM nginx:1.13-alpine

# certbot from letsencrypt
# openssl for self-signed certificates in dev mode
# gettext for envsubst
RUN apk add --no-cache certbot openssl gettext

RUN rm /etc/nginx/conf.d/default.conf
COPY nginx.conf /etc/nginx/
COPY conf/* /etc/nginx/conf.d/
COPY entrypoint.sh /entrypoint.sh
RUN chmod u+x /entrypoint.sh
VOLUME /etc/letsencrypt/
ENTRYPOINT ["/entrypoint.sh"]
CMD ["nginx"]
