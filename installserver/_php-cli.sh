#!/bin/bash

scriptPath=$(cd `dirname $0`; pwd)

if [ $UID -ne 0 ]
then
	echo "Use \"sudo\" to run this, or switch to root to run this."
	exit 1
fi


sudo touch /var/log/installserver.log
sudo chmod 666 /var/log/installserver.log

section="# ----- [ PHP (command-line) ] ----- #"
echo "$section"

sudo aptitude -q -y install php5-cli php5-mcrypt php5-imagick php5-mysql php5-gd \
	php-gettext php5-memcached php5-sqlite php-apc php5-intl php5-curl \
	>> /var/log/installserver.log 2>&1 
# install composer (package management tool)
#cd /usr/local/bin/;
#curl -s http://getcomposer.org/installer | php
#sudo chmod a+x /usr/local/bin/composer.phar
