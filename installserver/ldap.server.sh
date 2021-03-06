#!/bin/bash

scriptPath=$(cd `dirname $0`; pwd)

if [ $UID -ne 0 ]
then
	echo "Use \"sudo\" to run this, or switch to root to run this."
	exit 1
fi

if [ x"$LDAP_DOMAIN" == x -o x"$FIRST_USER_FIRST_NAME" == x -o x"$FIRST_USER_LAST_NAME" == x ]
then
	echo "usage: sudo LDAP_DOMAIN=example.com FIRST_USER_FIRST_NAME=Simon FIRST_USER_LAST_NAME=Tse $0"
	exit 0
fi

if [ x"$LDAP_DOMAIN" == x ]
then
	LDAP_DOMAIN=example.com
fi

DC=$(echo $LDAP_DOMAIN| sed 's/^/dc=/' | sed 's/\./,dc=/g')

CREATE_FIRST_USER=0

if [ x"$FIRST_USER_LAST_NAME" == x ]
then
	FIRST_USER_LAST_NAME=Tse
fi
if [ x"$FIRST_USER_FIRST_NAME" == x ]
then
	FIRST_USER_FIRST_NAME=Simon
fi
if [ x"$FIRST_USER_LOGIN" == x ]
then
	FIRST_USER_LOGIN=$(echo $FIRST_USER_FIRST_NAME | awk '{print tolower($0)}').$(echo $FIRST_USER_LAST_NAME | awk '{print tolower($0)}')
fi


section="# ----- [ LDAP Server ] ----- #"
echo "$section"

# https://help.ubuntu.com/lts/serverguide/openldap-server.html
## sudo apt-get -q -y remove --purge slapd
sudo apt-get -q -y install slapd ldap-utils ldapvi

## sudo rm -f /etc/phpldapadmin/nginx.conf && sudo apt-get -q -y remove --purge phpldapadmin
sudo apt-get -q -y install phpldapadmin
sudo sed -e -i "s/\$server->setValue('server','host'.*$/\$server->setValue('server','host','127.0.0.1');/" /etc/phpldapadmin/config.php
sudo sed -i "s/\$servers->setValue('server','base'.*/\$servers->setValue('server','base',array('$DC'));/" /etc/phpldapadmin/config.php
sudo sed -i "s/\$servers->setValue('login','bind_id'.*/\$servers->setValue('login','bind_id','cn=admin,$DC');/" /etc/phpldapadmin/config.php
sudo sed -i "s/^.*\$config->custom->appearance\['hide_template_warning'\].*$/\$config->custom->appearance\['hide_template_warning'\] = true;/" /etc/phpldapadmin/config.php
sudo sed -i "s/^.*\$servers->setValue('auto_number','min',.*$/\$servers->setValue('auto_number','min',array('uidNumber'=>8001,'gidNumber'=>7001));/" /etc/phpldapadmin/config.php
# http://stackoverflow.com/questions/20673186/getting-error-for-setting-password-field-when-creating-generic-user-account-phpl
sudo sed -i "s/\$default = \$this->getServer()->getValue('appearance','password_hash.*$/\$default = \$this->getServer()->getValue('appearance','password_hash_custom');/" /usr/share/phpldapadmin/lib/TemplateRender.php
##sudo sed -i "s/^.*\$servers->setValue('appearance','password_hash',.*$/\$servers->setValue('appearance','password_hash','ssha');/' /usr/share/phpldapadmin/config/config.php

# add a change password page for normal user : http://technology.mattrude.com/2010/11/ldap-php-change-password-webpage/
sudo rm -rf /usr/share/phpldapadmin/htdocs/passwd
cd /usr/share/phpldapadmin/htdocs/ ; sudo git clone https://gist.github.com/mattrude/657334 passwd
sudo mv /usr/share/phpldapadmin/htdocs/passwd/changepassword.php /usr/share/phpldapadmin/htdocs/passwd/index.php
sudo sed -i "s/\$dn = \"ou=.*/\$dn = \"ou=Users,$DC\";/" /usr/share/phpldapadmin/htdocs/passwd/index.php 
grep "Change Password For User" /usr/share/phpldapadmin/htdocs/welcome.php 2>&1 >/dev/null
if [ $? -ne 0 ]
then
	sudo sed -i  "/if (\$_SESSION\[APPCONFIG\]->isCommandAvailable('cmd','oslinks')) {/a\    printf('<a href=\"/passwd/\" target=\"_blank\" style=\"color:orange;\">Change Password For User</a> | ');" /usr/share/phpldapadmin/htdocs/welcome.php 
fi
grep "Change Password For User" /usr/share/phpldapadmin/lib/functions.php 2>&1 >/dev/null
if [ $? -ne 0 ]
then
	sudo sed -i "/IMGDIR,_('Home'))),/a\                                'passwd'=>array('title'=>'Change Password For User','enable'=>true,'link'=>'href=\"/passwd/\"','image'=>'')," /usr/share/phpldapadmin/lib/functions.php
fi
"$scriptPath"/_modify-phpldapadmin-template.php 

if ! [ -f /etc/ssl/certs/$LDAP_DOMAIN.crt ]
then
	sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/$LDAP_DOMAIN.key -out /etc/ssl/certs/$LDAP_DOMAIN.crt
fi

cat <<EOF | sudo tee /etc/phpldapadmin/nginx.conf
server {
        listen       80;
        server_name  ldap.$LDAP_DOMAIN;
        rewrite ^ https://\$http_host\$request_uri? permanent;    # force redirect http to https
}
server {
  listen                *:443 ssl;

  server_name           ldap.$LDAP_DOMAIN;
  ssl                   on;
  ssl_certificate       /etc/ssl/certs/$LDAP_DOMAIN.crt;
  ssl_certificate_key   /etc/ssl/private/$LDAP_DOMAIN.key;
  ssl_protocols         TLSv1 TLSv1.1 TLSv1.2;
  ssl_session_timeout 5m;

  ssl_ciphers EECDH+aRSA+AES256:EDH+aRSA+AES256:EECDH+aRSA+AES128:EDH+aRSA+AES128;
  ssl_session_cache shared:SSL:1m;
  ssl_prefer_server_ciphers on;
  add_header Strict-Transport-Security max-age=63072000;

  access_log            /var/log/nginx/ssl.ldap.$LDAP_DOMAIN.access.log main;
  root /usr/share/phpldapadmin/htdocs/;
  index index.php index.html index.htm;

  location ~ \.php\$ {
        fastcgi_intercept_errors        on;
        error_page 404 /error/404.php;
        fastcgi_pass php-fpm-backend;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header        X-Real-IP       \$remote_addr;
        proxy_set_header        X-Forwarded-For \$proxy_add_x_forwarded_for;
  }
}
EOF
sudo ln -sfn /etc/phpldapadmin/nginx.conf /etc/nginx/sites-available/ldap.$LDAP_DOMAIN.conf
sudo ln -sfn /etc/nginx/sites-available/ldap.$LDAP_DOMAIN.conf /etc/nginx/sites-enabled/ldap.$LDAP_DOMAIN.conf
sudo service nginx reload

sudo dpkg-reconfigure slapd
# ldapsearch -x -LLL -H ldap:/// -b dc=example,dc=com dn

# ldapsearch -x -LLL -b dc=example,dc=com 'uid=john' cn gidNumber
tmp=$(mktemp -d /tmp/XXXXXX)
touch $tmp/company.ldif
cat <<EOF > $tmp/company.ldif
dn: ou=Users,$DC
objectClass: organizationalUnit
ou: Users

dn: ou=Groups,$DC
objectClass: organizationalUnit
ou: Groups

EOF

#dn: cn=IT,ou=Groups,$DC
#objectClass: posixGroup
#cn: it
#gidNumber: 7001

if [ $CREATE_FIRST_USER -eq 1 ]
then
cat <<EOF >> $tmp/company.ldif
dn: uid=$FIRST_USER_LOGIN,ou=Users,$DC
objectClass: inetOrgPerson
objectClass: posixAccount
objectClass: shadowAccount
uid: $FIRST_USER_LOGIN
sn: $FIRST_USER_LOGIN
givenName: $FIRST_USER_FIRST_NAME
cn: $FIRST_USER_FIRST_NAME $FIRST_USER_LAST_NAME
displayName: $FIRST_USER_FIRST_NAME $FIRST_USER_LAST_NAME
uidNumber: 8001
gidNumber: 8001
userPassword: hello123
gecos: $FIRST_USER_FIRST_NAME $FIRST_USER_LAST_NAME
loginShell: /bin/bash
homeDirectory: /home/$FIRST_USER_LOGIN
EOF
fi

echo "Setup basic Users and Groups, and first user:"
ldapadd -x -D cn=admin,$DC -W -f $tmp/company.ldif

# sudo ldapmodify -Q -Y EXTERNAL -H ldapi:/// -f logging.ldif


rm -rf $tmp

echo "Visit http://ldap.$LDAP_DOMAIN/ to config users and groups. (You will need to set the DNS of ldap.$LDAP_DOMAIN)"

