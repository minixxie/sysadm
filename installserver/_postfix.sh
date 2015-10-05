#!/bin/bash

scriptPath=$(cd `dirname $0`; pwd)

if [ $UID -ne 0 ]
then
	echo "Use \"sudo\" to run this, or switch to root to run this."
	exit 1
fi


sudo touch /var/log/installserver.log
sudo chmod 666 /var/log/installserver.log

section="# ----- [ Postfix(SMTP-relay) ] ----- #"
echo "$section"
#**interactive on "postfix", required by mutt
sudo DEBIAN_FRONTEND=noninteractive aptitude -q -y install postfix
#sudo bash -c 'echo "mail.simon.com" > /etc/mailname'
#sudo postconf -e "myorigin = /etc/mailname"
#sudo postconf -e "myhostname = dev0001.simon.com"
#sudo postconf -e "relayhost=mail.simon.com"
#sudo postconf -e "inet_interfaces = loopback-only"

#sudo postconf -e "mydestination = localhost.localdomain, localhost"
#sudo postconf -e "inet_protocols = all"
#sudo postconf -e "mynetworks = 127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128"
sudo aptitude -q -y install mutt >> /var/log/installserver.log 2>&1

