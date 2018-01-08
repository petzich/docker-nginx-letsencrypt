FROM nginx:1.13-alpine

# add letsencrypt certbot (production) and openssl for dev mode
RUN apk add --no-cache certbot openssl

RUN rm /etc/nginx/conf.d/default.conf
COPY nginx.conf /etc/nginx/
COPY conf/* /etc/nginx/conf.d/
COPY entrypoint.sh /entrypoint.sh
RUN chmod u+x /entrypoint.sh
VOLUME /etc/letsencrypt/
ENTRYPOINT ["/entrypoint.sh"]
CMD ["nginx"]
