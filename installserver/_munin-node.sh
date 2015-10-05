#!/bin/bash

scriptPath=$(cd `dirname $0`; pwd)

if [ $UID -ne 0 ]
then
	echo "Use \"sudo\" to run this, or switch to root to run this."
	exit 1
fi


sudo touch /var/log/installserver.log
sudo chmod 666 /var/log/installserver.log

section="# ----- [ Munin(node) ] ----- #"
echo "$section"

sudo aptitude -q -y install munin-node >> /var/log/installserver.log 2>&1
# centralize all servers' statistics to munin.simon.net so that
# http://munin.simon.net will show all stats.
sudo sed -i 's/allow \^127\\.0\\.0\\.1\$$/allow \^munin\\.simon\\.net\$/' /etc/munin/munin-node.conf >> /var/log/installserver.log 2>&1
sudo service munin-node restart >> /var/log/installserver.log 2>&1

