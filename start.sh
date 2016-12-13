#! /bin/bash
# configte apahce
 a2ensite magento.conf
 a2dissite 000-default.conf

#configure PHP
 sed -i 's/memory_limit = 128MB/memory_limit = 2G/' /etc/php/7.0/apache2/php.ini
a2enmod rewrite
phpenmod mcrypt

# configure mysql
/usr/bin/mysqld_safe & 
 sleep 10s 

mysql -u root -e "create database magento; GRANT ALL ON magento.* TO magento@localhost IDENTIFIED BY 'magento';"
 killall mysqld

# start all the services
/usr/bin/supervisord
