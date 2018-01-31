#!/bin/sh
while :
do
  if [[ $SSL = true && -f /etc/letsencrypt/live/example.com/fullchain.pem ]]; then
    echo "Attempting to renew SSL certificate."
    certbot renew \
    --deploy-hook "echo 'Restarting container for renewed SSL Certificate' && /bin/kill -9 -1"
  fi
	sleep 43200
done
