#!/bin/bash

scriptPath=$(cd `dirname $0`; pwd)

if [ $UID -ne 0 ]
then
	echo "Use \"sudo\" to run this, or switch to root to run this."
	exit 1
fi


sudo touch /var/log/installserver.log
sudo chmod 666 /var/log/installserver.log

section="# ----- [ Virtualbox ] ----- #"
echo "$section"

# add line: source /etc/network/interfaces.d/*.cfg
grep "^source /etc/network/interfaces.d/" /etc/network/interfaces
if [ $? -ne 0 ] #not found
then
	echo "source /etc/network/interfaces.d/*.cfg" | sudo tee -a /etc/network/interfaces
fi

# add eth1.cfg
cat <<EOF | sudo tee /etc/network/interfaces.d/eth1.cfg
auto eth1
iface eth1 inet dhcp
EOF
sudo ifdown eth1 && sudo ifup eth1
