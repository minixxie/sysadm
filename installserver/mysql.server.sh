#!/bin/bash

scriptPath=$(cd `dirname $0`; pwd)

if [ $UID -ne 0 ]
then
	echo "Use \"sudo\" to run this, or switch to root to run this."
	exit 1
fi

mysqlRootPass=hello123
if [ x"$MYSQL_ROOT_PASS" != x ]
then
	mysqlRootPass="$MYSQL_ROOT_PASS"
fi


section="# ----- [ MySQL ] ----- #"
echo "$section"
##debconf-set-selections <<< 'mysql-server mysql-server/root_password password '$mysqlRootPass''
##debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password '$mysqlRootPass''
sudo DEBIAN_FRONTEND=noninteractive aptitude -o Aptitude::Cmdline::ignore-trust-violations=true -q -y install mysql-server >> /var/log/installserver.log 2>&1
##dpkg-reconfigure --frontend=noninteractive mysql-server >> /var/log/installserver.log 2>&1
sudo mysqladmin -u root password $mysqlRootPass
# dump timezone data
sudo mysql_tzinfo_to_sql /usr/share/zoneinfo 2>/dev/null | mysql -u root -p$mysqlRootPass mysql >> /var/log/installserver.log 2>&1
# bind-address=0.0.0.0, allow all other hosts to connect via TCP/IP
sudo sed -i "s/^bind-address.*/bind-address\t\t= 0.0.0.0/" /etc/mysql/my.cnf >> /var/log/installserver.log 2>&1
# set default timezone as UTC under [mysqld] section:
sudo sed -i '/\[mysqld\]/a\default_time_zone = UTC' /etc/mysql/my.cnf >> /var/log/installserver.log 2>&1
sudo service mysql restart >> /var/log/installserver.log 2>&1

