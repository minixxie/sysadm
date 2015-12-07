#!/bin/bash

scriptPath=$(cd `dirname $0`; pwd)

if [ $UID -ne 0 ]
then
	echo "Use \"sudo\" to run this, or switch to root to run this."
	exit 1
fi

section="# ----- [ GitLab ] ----- #"
echo "$section"

#https://about.gitlab.com/downloads/#ubuntu1404

#sudo apt-get -q -y install curl openssh-server ca-certificates postfix
#curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.deb.sh | sudo bash
#sudo apt-get -q -y install gitlab-ce
#sudo gitlab-ctl reconfigure

# http://doc.gitlab.com/omnibus/docker/

if [ x"$GIT_HOSTNAME" == x ]
then
	GIT_HOSTNAME=git.example.com
fi
if [ x"$HTTPS_CERT" == x ]
then
	HTTPS_CERT=/etc/ssl/certs/git.example.com.crt
fi
if [ x"$HTTPS_KEY" == x ]
then
	HTTPS_KEY=/etc/ssl/private/git.example.com.key
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

"$scriptPath"/../create-self-signed-https-cert.sh $GIT_HOSTNAME
sudo mv -f ./$GIT_HOSTNAME.crt /etc/ssl/certs/
sudo mv -f ./$GIT_HOSTNAME.key /etc/ssl/private

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

echo "To configure ldap, this script will open vi for you, and you'll need to write:"
echo "1) bind_dn: 'cn=name.surname,cn=People,dc=example,dc=com'"
echo "2) base: 'cn=People,dc=example,dc=com'"
echo "3) host: 'dockerhost'"
echo -n "Configure ldap usage? (y/n) "
read configLdap
if [ x"$configLdap" == x"Y" -o x"$configLdap" == x"y" ]
then
	sudo docker exec -it gitlab vi +/ldap_enabled /etc/gitlab/gitlab.rb 
	sudo docker restart gitlab 
fi
