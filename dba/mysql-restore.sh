#!/bin/bash

scriptPath=$(cd `dirname $0`; pwd)
. "$scriptPath"/../lib/uri_parser #import uri_parser function

if [ x"$1" = x ]
then
	echo "usage: MYSQL_URI=mysql://user:pass@host:port/dbName $0 file.sql.gz"
	exit 1
fi


if [ x"$MYSQL_URI" == x ]
then
	mysql="mysql"
else
    uri_parser $MYSQL_URI || { >&2 echo "Malformed MYSQL_URI"; exit 1; }
    mysqlSchema="$uri_schema"
    mysqlUser="$uri_user"
    mysqlPass="$uri_password"
    mysqlHost="$uri_host"
    mysqlPort=${uri_port:-3306}
    mysqlPath=$(basename "$uri_path")
	if [ x"$mysqlPath" == x"/" ]
	then
		mysqlPath=""
	fi

	mysql="mysql -h $mysqlHost -u $mysqlUser -p$mysqlPass $mysqlPath"
fi

echo "cat $1 | gunzip --to-stdout - | $mysql"
cat $1 | gunzip --to-stdout - | $mysql

