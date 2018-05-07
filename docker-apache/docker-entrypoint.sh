#!/bin/sh

set -e

cd /var/www/html

if [ ! -f /var/www/html/.env ]; then
   git clone https://github.com/saelos/saelos.git /var/www/html
fi

composer install --no-dev

npm install 

npm run prod

chown -R www-data:www-data /var/www/html

if [ -z "$SAELOS_DB_PASSWORD" ]; then

  echo >&2 "Warning: You need to create database yourself to continue install Saelos."

else

  echo >&2 "========================================================================"
  echo >&2
  echo >&2 "Setting Up MySQL Client"

  sed -i -e "s/MYUSER/$SAELOS_DB_USER/g" /root/.my.cnf
  sed -i -e "s/MYPASSWORD/$SAELOS_DB_PASSWORD/g" /root/.my.cnf
  sed -i -e "s/MYHOST/$SAELOS_DB_HOST/g" /root/.my.cnf
  sed -i -e "s/MYDATABASE/$SAELOS_DB_NAME/g" /root/.my.cnf

  mysql --batch --silent -e "CREATE DATABASE IF NOT EXISTS $SAELOS_DB_NAME DEFAULT CHARACTER SET utf8 COLLATE utf8_bin;";

  echo >&2 "========================================================================"
  echo >&2
  echo >&2 "This server is now configured to run Saelos!"
  echo >&2 "Database Hostname: $SAELOS_DB_HOST"
  echo >&2 "Database Name: $SAELOS_DB_NAME"
  echo >&2 "Database Username: $SAELOS_DB_USER"
  echo >&2 "Database Password: $SAELOS_DB_PASSWORD"

fi

# first arg is `-f` or `--some-option`
if [ "${1#-}" != "$1" ]; then
	set -- apache2-foreground "$@"
fi

exec "$@"
