#!/usr/bin/env bash

#generate config file
sleep $LIZMAP_SLEEP;
VAR="/var/www/websig/lizmap/var/config"

if [ ! -d $VAR ]; then
  echo "Creating Config file in /var"
  cp -ar /var/www/websig/lizmap/var_install/*  /var/www/websig/lizmap/var
fi

if [ ! -z "$POSTGRES_DB_AUTH_NAME" ]; then
  if [ ! -f /home/files/databases_installed ]; then
    echo "The postgresql databases for log and auth in lizmap are not already installed"
    #replace postgresql variables in profiles.ini.php for log and auth databases
    cp /home/files/profiles.ini.php /var/www/websig/lizmap/var/config/profiles.ini.php.dist
    sed -i "s/###DB_HOST###/${POSTGRES_HOST}/; s/###DB_AUTH_NAME###/${POSTGRES_DB_AUTH_NAME}/; s/###DB_LOGS_NAME###/${POSTGRES_DB_LOGS_NAME}/; s/###DB_USER###/${POSTGRES_USER}/; s/###DB_PASSWORD###/${POSTGRES_PASS}/" /var/www/websig/lizmap/var/config/profiles.ini.php.dist
    /var/www/websig/lizmap/install/reset.sh install
    touch /home/files/databases_installed
  else
    echo "The postgresql databases for log and auth in lizmap are already installed"
  fi
else
  cp /home/files/profiles.ini.php.dist /var/www/websig/lizmap/var/config/profiles.ini.php
fi

#set-rights
chown :www-data  /var/www/websig/lizmap/www -R
chmod 775  /var/www/websig/lizmap/www -R
chown :www-data /var/www/websig/lizmap/var -R
chmod 775  /var/www/websig/lizmap/var -R
/var/www/websig/lizmap/install/set_rights.sh www-data www-data
cp -ar /var/www/websig/lizmap/var /var/www/websig/lizmap/var_install

# Apache gets grumpy about PID files pre-existing
rm -f /var/run/apache2/apache2.pid

exec /usr/sbin/apachectl -D FOREGROUND
