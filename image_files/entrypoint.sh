#!/bin/sh
if [ ! -d /ghost_vol/content ]; then
  echo "Migrating /ghost/content to persistent volume."
  cp -r /ghost/content /ghost_vol/
fi

echo "Linking /ghost/content to persistent volume."
rm -r /ghost/content
ln -sv /ghost_vol/content /ghost/content

# copy and link ghost letsencrypt data to persistant volume
if [[ ! -d /ghost_vol/letsencrypt && $SSL = true ]]; then
  echo "Migrating /etc/letsencrypt to persistent volume."
  mkdir /ghost_vol/letsencrypt
  cp -r /etc/letsencrypt/* /ghost_vol/letsencrypt/
fi

if [ "$SSL" = true ]; then
  echo "Linking /etc/letsencrypt to persistent volume"
  rm -rf /etc/letsencrypt
  ln -sv /ghost_vol/letsencrypt /etc/letsencrypt
fi

supervisord -c /etc/supervisord.conf
