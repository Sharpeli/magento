# Build magento 2 from ubuntu base
FROM ubuntu:16.04

#Install build-essential, wget, curl, git, supervisor
RUN apt-get update \
    && apt-get install -y build-essential \
                       wget \
                       curl \
                       git \
                       supervisor

# Install apache2
RUN apt-get update \
    && apt-get -y install apache2

COPY magento.conf /etc/apache2/sites-available/
COPY docker-entrypoint.sh /docker-entrypoint.sh
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY session.php /session.php
COPY page_caching.php /page_caching.php

# Install PHP
   RUN apt-get -y update \
    && apt-get install -y php7.0 \
                           libapache2-mod-php7.0 \
                           php7.0 \
                           php7.0-common \
                           php7.0-gd \
                           php7.0-mysql \
                           php7.0-mcrypt \
                           php7.0-curl \
                           php7.0-intl \
                           php7.0-xsl \
                           php7.0-mbstring \
                           php7.0-zip \
                           php7.0-bcmath \
                           php7.0-iconv

#Install MySQL  nointeractive
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install mysql-server mysql-client

# Install Redis
RUN wget http://download.redis.io/redis-stable.tar.gz \
    && tar xvzf redis-stable.tar.gz

RUN cd redis-stable \
    && make \
    && make install

#Install  Compose
RUN  curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer

#Download Mangento and ready to install
RUN cd /var/www \
    && git clone https://github.com/magento/magento2.git magento \
    && cd magento \
    && composer install

EXPOSE 5000

ENTRYPOINT ["/bin/bash", "/docker-entrypoint.sh"]
