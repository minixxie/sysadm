#!/bin/bash

scriptPath=$(cd `dirname $0`; pwd)

if [ $UID -ne 0 ]
then
	echo "Use \"sudo\" to run this, or switch to root to run this."
	exit 1
fi

if [ x"$LDAP_DOMAIN" == x -o x"$GIT_HOSTNAME" == x ]
then
	echo "usage: sudo LDAP_DOMAIN=example.com GIT_HOSTNAME=git.example.com $0"
	exit 0
fi

section="# ----- [ GitLab ] ----- #"
echo "$section"

#https://about.gitlab.com/downloads/#ubuntu1404

#sudo apt-get -q -y install curl openssh-server ca-certificates postfix
#curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.deb.sh | sudo bash
#sudo apt-get -q -y install gitlab-ce
#sudo gitlab-ctl reconfigure

# http://doc.gitlab.com/omnibus/docker/

if [ x"$LDAP_DOMAIN" == x ]
then
	LDAP_DOMAIN=example.com
fi
DC=$(echo $LDAP_DOMAIN| sed 's/^/dc=/' | sed 's/\./,dc=/g')

if [ x"$GIT_HOSTNAME" == x ]
then
	GIT_HOSTNAME=git.example.com
fi
CERT_HOSTNAME=$GIT_HOSTNAME
if [ x"$WILDCARD" == x1 ]
then
	CERT_HOSTNAME=$(echo $GIT_HOSTNAME | sed 's/^[^.]*\.//')
fi

if [ x"$HTTPS_CERT" == x ]
then
	HTTPS_CERT=/etc/ssl/certs/$CERT_HOSTNAME.crt
fi
if [ x"$HTTPS_KEY" == x ]
then
	HTTPS_KEY=/etc/ssl/private/$CERT_HOSTNAME.key
fi
if [ x"$REVERSE_PROXY_HTTP_PORT" == x ]
then
	REVERSE_PROXY_HTTP_PORT=3000
fi
if [ x"$REVERSE_PROXY_HTTPS_PORT" == x ]
then
	REVERSE_PROXY_HTTPS_PORT=3001
fi

echo -n "This is to stop the gitlab container (if any), are you sure to proceed? (y/n) "
read toStopGitlab

if ! [ x"$toStopGitlab" == xY -o x"$toStopGitlab" == xy ]
then
	echo "Quit."
	exit 0
fi

sudo docker stop gitlab
sudo docker rm gitlab

sudo docker pull gitlab/gitlab-ce
sudo docker run --detach \
    --hostname $GIT_HOSTNAME \
    --publish $REVERSE_PROXY_HTTPS_PORT:443 --publish $REVERSE_PROXY_HTTP_PORT:80 --publish 15222:22 \
    --name gitlab \
    --restart always \
    --volume /srv/gitlab/config:/etc/gitlab \
    --volume /srv/gitlab/logs:/var/log/gitlab \
    --volume /srv/gitlab/data:/var/opt/gitlab \
    gitlab/gitlab-ce:latest

if ! [ -f /etc/ssl/certs/$CERT_HOSTNAME.crt ]
then
	sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout $HTTPS_KEY -out $HTTPS_CERT
fi

cat <<EOF | sudo tee /srv/gitlab/config/nginx.conf
server {
        listen       80;
        server_name  $GIT_HOSTNAME;
        rewrite ^ https://\$http_host\$request_uri? permanent;    # force redirect http to https
}
server {
  listen                *:443 ssl;
  server_name           $GIT_HOSTNAME;
  ssl                   on;
  ssl_certificate       $HTTPS_CERT;
  ssl_certificate_key   $HTTPS_KEY;
  ssl_protocols         TLSv1 TLSv1.1 TLSv1.2;
  ssl_session_timeout 5m;

  ssl_ciphers EECDH+aRSA+AES256:EDH+aRSA+AES256:EECDH+aRSA+AES128:EDH+aRSA+AES128;
  ssl_session_cache shared:SSL:1m;
  ssl_prefer_server_ciphers on;
  add_header Strict-Transport-Security max-age=63072000;

  access_log            /var/log/nginx/ssl.$GIT_HOSTNAME.access.log main;
  #client_max_body_size 100m; #allow migration of git repositories which normally have large pushes

  location / {
    proxy_pass http://127.0.0.1:$REVERSE_PROXY_HTTP_PORT;
    proxy_http_version 1.1;
    proxy_set_header Upgrade \$http_upgrade;
    proxy_set_header Connection 'upgrade';
    proxy_set_header        X-Real-IP       \$remote_addr;
    proxy_set_header        X-Forwarded-For \$proxy_add_x_forwarded_for;

  }
}
EOF

sudo ln -sfn /srv/gitlab/config/nginx.conf /etc/nginx/sites-available/$GIT_HOSTNAME
sudo ln -sfn /etc/nginx/sites-available/$GIT_HOSTNAME /etc/nginx/sites-enabled/$GIT_HOSTNAME
sudo service nginx reload


dockerHostIP=$(ifconfig docker0 | grep "inet addr" | sed 's/^[[:space:]]*//' | sed 's/^[^:]*://' | sed 's/  .*$//')

echo "To configure ldap, this script will open vi for you, and you'll need to copy these into config file:"
cat <<EOF
gitlab_rails['ldap_enabled'] = true
gitlab_rails['ldap_servers'] = YAML.load <<-'EOS' # remember to close this block with 'EOS' below
  main: # 'main' is the GitLab 'provider ID' of this LDAP server
    label: 'LDAP'
    host: '$dockerHostIP' #docker host IP here
    port: 389
    uid: 'uid'
    method: 'plain' # "tls" or "ssl" or "plain"
    bind_dn: 'cn=admin,$DC'
    password: '***YOUR LDAP ADMIN PASSWORD***'
    active_directory: true
    allow_username_or_email_login: true
    block_auto_created_users: false
    base: 'ou=Users,$DC' #allow all users
    user_filter: ''
    ## EE only
    #group_base: 'cn=IT,ou=Groups,$DC' #allow users in IT group only
    admin_group: ''
    sync_ssh_keys: false
EOS
EOF
echo -n "Configure ldap usage? (y/n) "
read configLdap
if [ x"$configLdap" == x"Y" -o x"$configLdap" == x"y" ]
then
	# open gitlab config file (ruby source code)
	sudo docker exec -it gitlab vi +/ldap_enabled /etc/gitlab/gitlab.rb 
	sudo docker restart gitlab 
fi
