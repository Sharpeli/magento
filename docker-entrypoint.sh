#!/bin/bash

# set the default value
set_default() {
	local var="$1"
        if [ ! "${!var:-}" ]; then
                 export "$var"="$2"
        fi
}

# the file env.php doesn't exitst means that magento hasn't been installed 
if [ ! -f /var/www/magento/app/etc/env.php ]; then 
	set_default 'ADMIN_FIRSTNAME' 'firstname'
	set_default 'ADMIN_LASTNAME' 'lastname'
	set_default 'ADMIN_EMAIL' 'sample@example.com'
	set_default 'ADMIN_USER' 'root'
  	set_default 'ADMIN_PASSWORD' 'password1234'
        set_default 'DB_NAME' 'magento'
	set_default 'DB_PASSWORD' 'password1234'
        set_default 'BACKEND_FRONTNAME' 'admin'

	# configure apache2
	a2ensite magento.conf
	a2dissite 000-default.conf

	#configure PHP
	sed -i 's/memory_limit = 128MB/memory_limit = 2G/' /etc/php/7.0/apache2/php.ini
	a2enmod rewrite
        phpenmod mcrypt
      
	# configure mysql
        service mysql start
 	mysqladmin -u root password $DB_PASSWORD
        mysql -u root -e "create database magento; GRANT ALL ON magento.* TO magento@localhost IDENTIFIED BY 'magento';" --password=$DB_PASSWORD
 	
	# install the magento
        /var/www/magento/bin/magento setup:install --admin-firstname=$ADMIN_FIRSTNAME \
          					   --admin-lastname=$ADMIN_LASTNAME \
						   --admin-email=$ADMIN_EMAIL \
						   --admin-user=$ADMIN_USER \
						   --admin-password=$ADMIN_PASSWORD \
						   --db-name=$DB_NAME \
  						   --db-password=$DB_PASSWORD \
						   --backend-frontname=$BACKEND_FRONTNAME \
						   --base-url=$BASE_URL		

	# check if install magento successfully
	if [ -f /var/www/magento/app/etc/env.php ]; then 
		# configure redis
		sed -e "/'save' => 'files',/ {" -e "r /session.php" -e "d" -e "}" -i /var/www/magento/app/etc/env.php
		sed -e "/);/ {" -e "r /page_caching.php" -e "d" -e "}" -i /var/www/magento/app/etc/env.php
	fi
fi

# check if mysql is running
if ! service mysql status; then
	service mysql start
fi

#start redis in the background
redis-server --daemonize yes

# set magento2 mode to production 
/var/www/magento/bin/magento deploy:mode:set production

#set file permissions
chmod u+x /var/www/magento/bin/magento
chmod -R 2777 /var/www/magento/var /var/www/magento/pub/media /var/www/magento/pub/static /var/www/magento/app/etc

# enable start cron jobs every minutes
service cron restart
crontab -l > magentocron
cat cronjobs >> magentocron
crontab magentocron
rm magentocron

echo "Waiting cron jobs to start..."
while [ ! -f /var/www/magento/var/.setup_cronjob_status ]; do
       sleep 1s
done

# run apache in the foreground
apachectl -DFOREGROUND
