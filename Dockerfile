# Build magento 2 from ubuntu base
FROM ubuntu:16.04

ENV MAGENTO_VERSION 2.1.3

#Install build-essential, wget, curl, git, supervisor
RUN apt-get update \
    && apt-get install -y build-essential \
                       wget \
                       curl \
		       cron

# Install apache2 
RUN apt-get update \ 
    && apt-get -y install apache2 

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
RUN cd && curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer

#Download Mangento and ready to install
RUN cd /var/www \
    && mkdir magento \
    && wget https://raw.githubusercontent.com/Sharpeli/Packages/master/Magento-CE-2_1_3_tar_gz-2016-12-13-09-08-39.tar.gz \
    &&  tar xvzf ./Magento-CE-2_1_3_tar_gz-2016-12-13-09-08-39.tar.gz -C ./magento

# set file permissions
RUN	chmod -R 755 /var/www/magento/ \
	&& chmod -R 777 /var/www/magento/app/etc/ \
        && chmod -R 777 /var/www/magento/var/ \ 
	&& chmod -R 777 /var/www/magento/pub/media/ \ 
	&& chmod -R 777 /var/www/magento/pub/static/ 

COPY magento.conf /etc/apache2/sites-available/
COPY docker-entrypoint.sh /docker-entrypoint.sh
COPY session.php /session.php
COPY page_caching.php /page_caching.php
COPY cronjobs /cronjobs

# change permissions for docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

EXPOSE 80

ENTRYPOINT ["/docker-entrypoint.sh"]
