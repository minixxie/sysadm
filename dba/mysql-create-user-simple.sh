#!/bin/bash

echo -n "User: "
read mysqlUser
echo -n "Pass: "
read mysqlPass
echo -n "DB: "
read mysqlDB

mysql -u root -p <<EOF
grant all privileges on $mysqlDB.* to $mysqlUser@'192.168.%' identified by '$mysqlPass';
EOF
