#!/bin/bash

scriptPath=$(cd `dirname $0`; pwd)

if [ $UID -ne 0 ]
then
	echo "Use \"sudo\" to run this, or switch to root to run this."
	exit 1
fi


sudo touch /var/log/installserver.log
sudo chmod 666 /var/log/installserver.log

section="# ----- [ NTP(Network Time Server) ----- #"
echo "$section"

# reference: https://help.ubuntu.com/10.04/serverguide/C/NTP.html
sudo aptitude -q -y install ntp >> /var/log/installserver.log 2>&1
# add 4 time server sources under "server ntp.ubuntu.com"
ntpConf=/etc/ntp.conf
# NO NEED TO ADD 4 TIME SERVERS ANYMORE AS BY DEFAULT [0-3].ubuntu.pool.ntp.org are configured in Ubuntu-12.04
#sed -i "/server ntp.ubuntu.com/a\server 3.asia.pool.ntp.org" $ntpConf >> /var/log/installserver.log 2>&1
#sed -i "/server ntp.ubuntu.com/a\server 2.asia.pool.ntp.org" $ntpConf >> /var/log/installserver.log 2>&1
#sed -i "/server ntp.ubuntu.com/a\server 1.asia.pool.ntp.org" $ntpConf >> /var/log/installserver.log 2>&1
#sed -i "/server ntp.ubuntu.com/a\server 0.asia.pool.ntp.org" $ntpConf >> /var/log/installserver.log 2>&1
sudo service ntp stop >> /var/log/installserver.log 2>&1
# fix the system clock
sudo ntpdate `cat /etc/ntp.conf | grep "^server" | sed 's/server //'` >> /var/log/installserver.log 2>&1
sudo service ntp restart >> /var/log/installserver.log 2>&1

