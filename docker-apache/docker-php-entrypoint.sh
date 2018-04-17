#!/bin/sh
set -e

cd /var/www/html

if [ ! -f /var/www/html/.env ]; then
   git clone https://github.com/saelos/saelos.git .
fi

composer install --no-dev

npm install 

npm run prod

chown -R www-data:www-data /var/www/html

# first arg is `-f` or `--some-option`
if [ "${1#-}" != "$1" ]; then
	set -- apache2-foreground "$@"
fi

exec "$@"
