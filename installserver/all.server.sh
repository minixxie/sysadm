#!/bin/bash

scriptPath=$(cd `dirname $0`; pwd)

if [ $UID -ne 0 ]
then
	echo "Use \"sudo\" to run this, or switch to root to run this."
	exit 1
fi


sudo touch /var/log/installserver.log
sudo chmod 666 /var/log/installserver.log

section="# ----- [ Post-Installation ] ----- #"
echo "$section"
sudo apt-get update >> /var/log/installserver.log 2>&1
sudo apt-get -q -y install aptitude >> /var/log/installserver.log 2>&1
sudo aptitude update >> /var/log/installserver.log 2>&1
sudo aptitude -q -y install openssh-server >> /var/log/installserver.log 2>&1
sudo aptitude -q -y install git tig >> /var/log/installserver.log 2>&1

"$scriptPath"/_ntp.sh
#"$scriptPath"/_network.sh
"$scriptPath"/_misc.sh
#"$scriptPath"/_postfix.sh
#"$scriptPath"/_nfs.sh
#"$scriptPath"/_munin-node.sh
"$scriptPath"/_php-cli.sh
#"$scriptPath"/_cpp.sh
#"$scriptPath"/_java.sh #need interaction
