#!/bin/bash

scriptPath=$(cd `dirname $0`; pwd)

if [ $UID -ne 0 ]
then
	echo "Use \"sudo\" to run this, or switch to root to run this."
	exit 1
fi

section="# ----- [ LDAP Client ] ----- #"
echo "$section"

# http://www.solaris11.com/redhat-centos-ubuntu/configure-an-openldap-server-on-ubuntu-14-04-and-authentication-linux-client-with-it/

sudo apt-get -q -y install ldap-auth-client nscd
# sudo dpkg-reconfigure ldap-auth-config
sudo auth-client-config -t nss -p lac_ldap
sudo sed -i 's/use_authtok//' /etc/pam.d/common-password  #make "passwd" command works for LDAP
# auto-create home directory
cat <<EOF | sudo tee /usr/share/pam-configs/ldap-mkhome
Name: activate mkhomedir
Default: yes
Priority: 900
Session-Type: Additional
Session:
	required pam_mkhomedir.so umask=0022 skel=/etc/skel
EOF
sudo pam-auth-update 
sudo service nscd restart
