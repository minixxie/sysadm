#!/bin/bash

if [ x"$1" == x ]
then
	echo "usage: [WILDCARD=1] $0 doman-name.com"
	exit 0
fi

domainName="$1"

### sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/$CERT_HOSTNAME.key -out /etc/ssl/certs/$CERT_HOSTNAME.crt


tmp=$(mktemp -d /tmp/XXXXXX)
chmod 700 $tmp

openssl genrsa -des3 -passout pass:x -out $tmp/server.pass.key 2048
openssl rsa -passin pass:x -in $tmp/server.pass.key -out $domainName.key
rm $tmp/server.pass.key
openssl req -new -key $domainName.key -out $domainName.csr
openssl x509 -req -days 365 -in $domainName.csr -signkey $domainName.key -out $domainName.crt
