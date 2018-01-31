FROM alpine:3.5
ARG url
ARG domain_name
ARG email
ARG ssl

RUN echo "@community http://dl-2.alpinelinux.org/alpine//v3.5/community" >> /etc/apk/repositories

RUN apk update && apk upgrade && apk -U add \
  nodejs \
  sqlite \
  python \
  g++ \
  make \
  nginx \
  sudo \
  supervisor \
  jq \
  curl \
  certbot@community

# Configure NGINX
COPY image_files/nginx.conf /etc/nginx/nginx.conf
RUN sed -i s/example\.com/$domain_name/ /etc/nginx/nginx.conf
RUN echo
RUN test "$ssl" = true && sed -i 's/^#//' /etc/nginx/nginx.conf; exit 0

# Create ghost group and user
RUN addgroup -S ghost
RUN adduser -SDH -G ghost ghost

# Install Ghost
RUN npm install -g ghost-cli
RUN mkdir ghost
RUN cd ghost && echo $url | ghost install \
  --version=1.20.2 \
  --process=local \
  --no-stack \
  --no-setup-ssl \
  --no-setup-linux-user \
  --no-setup-nginx \
  --no-start \
  --db sqlite3 \
  --dbpath ./content/data/ghost.db

# Configure Ghost
COPY config.json /ghost/config.override.json
RUN mv /ghost/config.production.json /ghost/config.production.bk.json
RUN cd /ghost && jq -s '.[0] * .[1]' config.production.bk.json config.override.json > config.production.json

# Setup http server scripts
COPY image_files/http_server.sh /http_server.sh
RUN sed -i s/example\.com/$domain_name/ /http_server.sh
COPY image_files/cert_renew.sh /cert_renew.sh
RUN sed -i s/example\.com/$domain_name/ /cert_renew.sh

# Configure supervisor
COPY image_files/supervisord.conf /etc/supervisord.conf
COPY image_files/supervisord-watchdog /usr/sbin/supervisord-watchdog

ENV NODE_ENV production
ENV EMAIL $email
ENV DOMAIN_NAME $domain_name
ENV SSL $ssl

COPY image_files/entrypoint.sh /entrypoint.sh
ENTRYPOINT ./entrypoint.sh
