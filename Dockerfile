# Build magento 2 from ubuntu base
FROM ubuntu:16.04

# Enivronment Variables
# ENV MYSQL_PASSWORD password
# ENV ADMIN_FIRSTNAME first
# ENV ADMIN_LASTNAME last
# ENV ADMIN_USER admin
# ENV ADMIN_EMAIL example@email.com
# ENV ADMIN_PASSWORD password1234

# Install utils
RUN  apt-get update \
     && apt-get install -y apt-utils

#Install Dependencies
RUN apt-get update \
    && apt-get install -y build-essential \
                       wget \
                       curl \
                       git

# Install apache2
RUN apt-get update \
    && apt-get -y install apache2

COPY magento.conf /etc/apache2/sites-available/

RUN a2ensite magento.conf \
    && a2dissite 000-default.conf

# RUN service apache2 reload
RUN service apache2 restart

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
# Configure PHP
 RUN  sed -i 's/memory_limit = 128MB/memory_limit = 2G/' /etc/php/7.0/apache2/ph                                                                                                                     p.ini
 RUN  a2enmod rewrite
 RUN  phpenmod mcrypt
 RUN service apache2 restart

# MySQL
RUN echo "mysql-server mysql-server/root_password password password" | debconf-s                                                                                                                     et-selections \
    && echo "mysql-server mysql-server/root_password_again password password" |                                                                                                                      debconf-set-selections \
    && apt install -y mysql-server mysql-client

# RUN mysql -u root -e "create database magento; GRANT ALL ON magento.* TO magen                                                                                                                     to@localhost IDENTIFIED BY 'magento';" --password=password

# Redis
RUN wget http://download.redis.io/redis-stable.tar.gz \
    && tar xvzf redis-stable.tar.gz

RUN cd redis-stable \
    && make \
    && make install

# Compose
RUN  curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer

# Mangento
RUN cd /var/www \
    && git clone https://github.com/magento/magento2.git magento \
    && cd magento \
    && composer install

# File Permissions
   RUN chmod -R 755 /var/www/magento/ \
       && chmod -R 777 /var/www/magento/app/etc \
       && chmod -R 777 /var/www/magento/var/ \
       && chmod -R 777 /var/www/magento/pub/media \
       && chmod -R 777 /var/www/magento/pub/static

CMD ["apachectl", "-DFOREGROUND"]

EXPOSE 80
