#!/bin/bash

md5=$(if [ `uname` == Darwin ] ; then echo md5 ; else echo md5sum ; fi)
randPass=$(date +"%s" | $md5 | base64)

tmpfile=$(mktemp /tmp/XXXXXX)

dialog --backtitle "System Administration Tool" --title "Create Mongo Database and DB user" \
--form "\n* siteUserAdmin is for login, if login is not needed:\n  set both siteUserAdmin & siteUserAdmin to empty\n* Will create DB user (password is randomly generated)\n* Will create DB name" 25 70 16 \
"siteUserAdmin(user):" 1 1 "siteUserAdmin" 1 25 35 30 \
"siteUserAdmin(pass):" 2 1 "" 2 25 35 30 \
"DB user(user):" 3 1 "" 3 25 35 30 \
"DB user(pass):" 4 1 "$randPass" 4 25 35 30 \
"DB name:" 5 1 "" 5 25 35 30 \
"role:" 6 1 "readWrite" 6 25 35 30 \
2> $tmpfile

if [ $? -eq 0 ]
then
	nonEmptyFields=$(cat $tmpfile | grep -v "^$" | wc -l)
	if [ $nonEmptyFields -lt 4 ] #at least give 4 (the last 4 fields)
	then
		printf "\x1B[31m"
		echo "ERR: Please fill all necessary fields."
		printf "\x1B[0m"
		exit 1
	fi

	siteUserAdmin_user=$(cat $tmpfile | head -n 1 | tail -n 1)
	siteUserAdmin_pass=$(cat $tmpfile | head -n 2 | tail -n 1)
	dbUser_user=$(cat $tmpfile | head -n 3 | tail -n 1)
	dbUser_pass=$(cat $tmpfile | head -n 4 | tail -n 1)
	dbName=$(cat $tmpfile | head -n 5 | tail -n 1)
	role=$(cat $tmpfile | head -n 6 | tail -n 1)

	
	mongo="mongo admin -u$siteUserAdmin_user -p$siteUserAdmin_pass"
	if [ x$siteUserAdmin_user == x -o x$siteUserAdmin_pass == x ]
	then
		mongo="mongo"
	fi
	$mongo << EOF
use $dbName;
db.dropDatabase();
use $dbName;
db.dropUser("$dbUser_user");
	db.createUser({
		user:"$dbUser_user",pwd:"$dbUser_pass",
		roles:[
			{role:"$role",db:"$dbName"}
		]
	});
EOF
	
fi

rm -f $tmpfile
