#!/bin/bash

set_default() {
	local var = "$1"
	if [ "${var}" = "" ]; then
		export "$var"="$2"
	fi
}

# the file env.php doesn't exitst means that magento hasn;t been insalled
if [! -f /var/www/magento/app/etc/env.php]; then
	set_default 'ADMIN_FIRSTNAME' 'firstname'
	set_default 'ADMIN_LASTNAME' 'lastname'
	set_default 'ADMIN_EMAIL' 'sample@example.com'
	set_default 'ADMIN_USER' 'root'
  	set_default 'ADMIN_PASSWORD' 'password'
        set_default 'DB_NAME' 'magento'
	set_default 'DB_PASSWORD' 'password'
        set_default 'BACKEND_FRONTNAME' 'admin'

	# configure apache
	 a2ensite magento.conf
	 a2dissite 000-default.conf

	#configure PHP
	 sed -i 's/memory_limit = 128MB/memory_limit = 2G/' /etc/php/7.0/apache2/php.ini
	a2enmod rewrite

	# configure mysql
	if /usr/bin/mysqld_safe; then
		mysqladmin -u root password $DB_PASSWORD
        	mysql -u root -e "create database magento; GRANT ALL ON magento.* TO magento@localhost IDENTIFIED BY 'magento';" -p $DB_PASSWORD
	fi
        
        # set file permission for installation
        chmod -R 755 /var/www/magento/
        chmod -R 755 /var/www/magento/app/etc
        chmod -R 755 /var/www/magento/var/
        chmod -R 755 /var/www/magento/pub/media
        chmod -R 755 /var/www/magento/pub/static
        
        # install the magento
        /var/www/magento/bin/magento setup:install --admin-firstname=$ADMIN_FIRSTNAME \
          					   --admin-lastname=$ADMIN_LASTNAME \
						   --admin-email=$ADMIN_EAMIL \
						   --admin-user=$ADMIN_USER \
						   --admin-password=$ADMIN_PASSWORD \
						   --db-name=$DB_NAME \
  						   --db-password=$DB__PASSWORD \
						   --backend-frontname=$BACKEND_FRONTNAME
	#configure redis
	if [ -f /var/www/magento/app/etc/env.php ]; then 
		sed -e "/'save' => 'files',/ {" -e "r session.conf" -e "d" -e "}" -i /var/www/magento/app/etc/env.php
		sed -e "/);/ {" -e "r page_caching.conf" -e "d" -e "}" -i /var/www/magento/bin/magento/app/etc/env.php
	fi
fi
		
# start all the services
/usr/bin/supervisord
