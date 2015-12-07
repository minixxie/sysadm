#!/bin/bash

scriptPath=$(cd `dirname $0`; pwd)

if [ $UID -ne 0 ]
then
	echo "Use \"sudo\" to run this, or switch to root to run this."
	exit 1
fi

section="# ----- [ LDAP ] ----- #"
echo "$section"

# https://help.ubuntu.com/lts/serverguide/openldap-server.html
sudo apt-get -q -y install slapd ldap-utils
sudo dpkg-reconfigure slapd
# ldapsearch -x -LLL -H ldap:/// -b dc=example,dc=com dn

# ldapsearch -x -LLL -b dc=example,dc=com 'uid=john' cn gidNumber
ldapadd -x -D cn=admin,dc=example,dc=com -W -f company.ldif

# sudo ldapmodify -Q -Y EXTERNAL -H ldapi:/// -f logging.ldif
