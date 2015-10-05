#!/bin/bash

scriptPath=$(cd `dirname $0`; pwd)

if [ $UID -ne 0 ]
then
	echo "Use \"sudo\" to run this, or switch to root to run this."
	exit 1
fi

section="# ----- [ Gearman server ] ----- #"
echo "$section"
sudo aptitude -q -y install gearman-job-server
sudo service gearman-job-server restart
sudo aptitude -q -y install php5-gearman
#sudo aptitude -q -y install libgearman6 libgearman-dev
#sudo aptitude -q -y install php5-dev #libssl-dev libssl
#sudo aptitude -q -y install php-pear
#sudo aptitude -q -y install make
#sudo pecl install channel://pecl.php.net/gearman-1.0.3
#sudo bash -c 'echo "extension=gearman.so" > /etc/php5/conf.d/gearman.ini'


