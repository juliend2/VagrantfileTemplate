#!/usr/bin/env bash

DB_USER=myuser
DB_PASS=mypass
DB_NAME=dbname

# Set MySQL root password:
sudo debconf-set-selections <<< 'mysql-server-5.5 mysql-server/root_password password root'
sudo debconf-set-selections <<< 'mysql-server-5.5 mysql-server/root_password_again password root'

# Update apt-get and install the packages we need:
if [ ! -f /var/log/packagessetup ];
then
  apt-get update
  apt-get -y install \
    build-essential git curl \
    mysql-server-5.5 php5-mysql libsqlite3-dev apache2 php5 php5-dev php-pear 

  touch /var/log/packagessetup
  
fi

# Set timezone
echo "America/Montreal" | sudo tee /etc/timezone
sudo dpkg-reconfigure --frontend noninteractive tzdata

# Setup database
if [ ! -f /var/log/databasesetup ];
then
  echo "DROP DATABASE IF EXISTS test" | mysql -uroot -proot
  echo "CREATE USER '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASS'" | mysql -uroot -proot
  echo "CREATE DATABASE $DB_NAME" | mysql -uroot -proot
  echo "GRANT ALL ON $DB_NAME.* TO '$DB_USER'@'localhost'" | mysql -uroot -proot
  echo "flush privileges" | mysql -uroot -proot

  touch /var/log/databasesetup

  # import mysql db
  if [ -f /vagrant/sql/dump.sql ];
  then
    mysql -uroot -proot $DB_NAME < /vagrant/sql/dump.sql
  fi
fi

# Apache changes
if [ ! -f /var/log/webserversetup ];
then
  # use our local project directory as the www directory
  rm -rf /var/www
  ln -fs /vagrant /var/www

  # configure apache
  echo "ServerName localhost" | tee /etc/apache2/httpd.conf > /dev/null
  a2enmod rewrite
  sed -i '/AllowOverride None/c AllowOverride All' /etc/apache2/sites-available/default

  touch /var/log/webserversetup
fi


# Configure PHP
if [ ! -f /var/log/phpsetup ];
then
    sudo sed -i '/display_errors = Off/c display_errors = On' /etc/php5/apache2/php.ini
    sudo sed -i '/error_reporting = E_ALL & ~E_DEPRECATED/c error_reporting = E_ALL | E_STRICT' /etc/php5/apache2/php.ini

    sudo touch /var/log/phpsetup
fi



