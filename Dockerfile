FROM php:7.1-apache

LABEL maintainer="Luiz Eduardo <luiz@powertic.com>"

# Install PHP extensions
RUN apt-get update && apt-get install --no-install-recommends -y \
      build-essential \
      libicu-dev \
      cron \
      libc-client-dev \
      libicu-dev \
      libkrb5-dev \
      libmcrypt-dev \
      libpq-dev \
      libssl-dev \
      git \
      zip \
      mysql-client \
      unzip \
      g++ \
      libmagickwand-dev \
      imagemagick \
      libpng-dev \
      zlib1g-dev \
      libzip-dev \
      libfreetype6-dev \
      libssl-dev \
      libmcrypt-dev \
      wget \
      curl \
      gnupg \
      libmcrypt-dev \
    && rm -r /var/lib/apt/lists/*

RUN docker-php-ext-install mbstring intl zip exif \
    && docker-php-ext-configure pdo_mysql --with-pdo-mysql=mysqlnd \
    && docker-php-ext-install \
      intl \
      mbstring \
      mcrypt \
      pcntl \
      pdo_mysql \
      pdo_pgsql \
      pgsql \
      zip \
      opcache \
      && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
      && rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-configure imap --with-imap --with-imap-ssl --with-kerberos \
    && docker-php-ext-install imap  \
    && docker-php-ext-enable imap

RUN docker-php-ext-configure gd \
      --enable-gd-native-ttf \
      --with-jpeg-dir=/usr/lib \
      --with-freetype-dir=/usr/include/freetype2 && \
    docker-php-ext-install gd

RUN pecl install imagick -y

RUN docker-php-ext-enable imagick

WORKDIR /var/www/html

ENV SAELOS_DB_USER 'root'
ENV SAELOS_DB_PASSWORD ''
ENV SAELOS_DB_HOST 'localhost'
ENV SAELOS_DB_NAME 'saelos'

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer

RUN curl -sL https://deb.nodesource.com/setup_9.x | bash -

RUN apt-get install -y nodejs

# Put apache config for Laravel
COPY docker-apache/apache2-laravel.conf /etc/apache2/sites-available/laravel.conf

RUN a2dissite 000-default.conf && a2ensite laravel.conf && a2enmod rewrite

VOLUME /var/www/html

COPY my.cnf /root/.my.cnf

COPY docker-apache/docker-entrypoint.sh /usr/local/bin/

RUN ln -s usr/local/bin/docker-entrypoint.sh /entrypoint.sh # backwards compat

RUN ["chmod", "+x", "/usr/local/bin/docker-entrypoint.sh"]

ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 80

CMD ["apache2-foreground"]
