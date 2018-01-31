#!/bin/sh
while [[ "$SSL" == true && ! -f /etc/letsencrypt/live/example.com/fullchain.pem ]]
do
  echo "Certifying SSL Certificate for $DOMAIN_NAME for $EMAIL."
  certbot certonly -n --agree-tos --standalone --preferred-challenges http --email $EMAIL -d $DOMAIN_NAME
	sleep 1800
done

echo "Starting NGINX, SSL: $SSL"
/usr/sbin/nginx
