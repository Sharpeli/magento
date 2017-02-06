#!/bin/bash
# Set the default values for environment variables
set_default() {
        local var="$1"
        if [ ! "${!var:-}" ]; then
                 export "$var"="$2"
        fi
}

# Convert bool value to number output
convert_to_num() {
	if [ ${1,,} = "true" ]; then
		echo "1"
	else
		echo "0"
	fi
}

# Start redis in the background
redis-server --daemonize yes

# Start mysql service when the environment variable 'MYSQLCONNSTR_defaultConnection' is empty
if [ -z "$MYSQLCONNSTR_defaultConnection" ]; then
	service mysql start
fi

# Start cron service
service cron start

cd /var/www/magento

# The file env.php doesn't exitst means that magento hasn't been installed yet
if [ ! -f app/etc/env.php ]; then
	set_default 'ADMIN_FIRSTNAME' 'firstname'
        set_default 'ADMIN_LASTNAME' 'lastname'
        set_default 'ADMIN_EMAIL' 'sample@example.com'
        set_default 'ADMIN_USER' 'root'
        set_default 'ADMIN_PASSWORD' 'MS173m_QN'
        set_default 'BACKEND_FRONTNAME' 'admin_1qn'
        set_default 'PRODUCTION_MODE' 'false'
        set_default 'USE_REWRITES' 'true'
        set_default 'ADMIN_USE_SECURITY_KEY' 'true'
		
	# if the environment variable MYSQLCONNSTR_defaultConnection has value, the magento site will use it as connection string to access mysql database, else the mysql in the image will be used
	if [ ! -z "$MYSQLCONNSTR_defaultConnection" ]; then
	      	export DB_HOST=$(echo $MYSQLCONNSTR_defaultConnection | perl -nle 'm/^.*Data Source=(.+?);.*$/; print $1')
		export DB_NAME=$(echo $MYSQLCONNSTR_defaultConnection | perl -nle 'm/^.*Database=(.+?);.*$/; print $1')
		export DB_USER=$(echo $MYSQLCONNSTR_defaultConnection | perl -nle 'm/^.*User Id=(.+?);.*$/; print $1')
		export DB_PASSWORD=$(echo $MYSQLCONNSTR_defaultConnection | perl -nle 'm/^.*Password=(.+?)$/; print $1')
        else
		export DB_HOST=localhost
		set_default 'DB_NAME' 'magento'
		set_default 'DB_USER' 'magento'
		set_default 'DB_PASSWORD' 'MS173m_QN'
		set_default 'MYSQL_ROOT_PASWORD' 'MS173m_QN'
	        set_default 'APACHE_USER' 'apache'
	        set_default 'APACHE_PASSWORD' 'MS173m_QN'
	        set_default 'PHPMYADMIN_PASSWORD' 'MS173m_QN'
	
		# Create username and password for apache2 authentication to secure phpmyadmin
		htpasswd -b -c /etc/phpmyadmin/.htpasswd  $APACHE_USER $APACHE_PASSWORD

       		# Set mysql password and creat table for magento2
        	mysqladmin -u root password $MYSQL_ROOT_PASWORD
        	mysql -u root -e "create database $DB_NAME; GRANT ALL ON $DB_NAME.* TO $DB_USER@localhost IDENTIFIED BY '$DB_PASSWORD';" --password=$MYSQL_ROOT_PASWORD

        	# Change phpmyadmin password according to users setting
        	mysql -u root -e "ALTER USER 'phpmyadmin'@'localhost' IDENTIFIED WITH mysql_native_password BY '$PHPMYADMIN_PASSWORD'" --password=$MYSQL_ROOT_PASWORD
        	sed -i "s/\$dbpass=.*/\$dbpass='$PHPMYADMIN_PASSWORD';/" /etc/phpmyadmin/config-db.php
	
	fi
		
        # Configure apache2 and PHP
        a2ensite magento.conf
        a2dissite 000-default.conf
        a2enmod rewrite
        phpenmod mcrypt
        phpenmod mbstring
	
        # Install the magento2
        bin/magento setup:install --admin-firstname=$ADMIN_FIRSTNAME \
                                                   --admin-lastname=$ADMIN_LASTNAME \
                                                   --admin-email=$ADMIN_EMAIL \
                                                   --admin-user=$ADMIN_USER \
                                                   --admin-password=$ADMIN_PASSWORD \
						   --db-host=$DB_HOST \
                                                   --db-name=$DB_NAME \
						   --db-user=$DB_USER \
                                                   --db-password=$DB_PASSWORD \
                                                   --backend-frontname=$BACKEND_FRONTNAME \
						   --use-rewrites=$(convert_to_num $USE_REWRITES) \
						   --admin-use-security-key=$(convert_to_num $ADMIN_USE_SECURITY_KEY) \
					           --base-url=$BASE_URL

        # Check if magento2 installed successfully
        if [ -f app/etc/env.php ]; then

                # Configure magento2 to use redis as cache tool
		php /redis.php
		sed -i '1s/.*/return array (/' /env-tmp.php
		sed -i '$s/$/;/' /env-tmp.php
		sed -i '1 i\<?php' /env-tmp.php
		cat /env-tmp.php > app/etc/env.php
		rm /env-tmp.php		 

		if [ "${PRODUCTION_MODE,,}" = "true" ] ; then

        	        # Switch the magento2 mode to production, we will enable this process until it can proceed on azure web app for linux
               		echo "switch magento to production mode..."
                	bin/magento deploy:mode:set production

			echo "setting file permissions for production mode..."
			find var vendor lib pub/static pub/media app/etc -type f -exec chmod g+w {} \;
			find var vendor lib pub/static pub/media app/etc -type d -exec chmod g+w {} \;
			chmod o+rwx app/etc/env.php
		else
			# Default mode
			echo "setting file permissions for default mode..."
			find var pub/static pub/media app/etc -type f -exec chmod g+w {} \;
			find var pub/static pub/media app/etc -type d -exec chmod g+ws {} \;
		fi
		
		echo "schedule cron jobs to run every minute..."
		crontab -l > magentocron
		cat /cronjobs >> magentocron
		crontab magentocron
		rm magentocron
        fi
fi

echo "run cron jobs the first time..."
php bin/magento cron:run
php bin/magento cron:run

# Run apache in the foreground
apachectl -DFOREGROUND
