#!/bin/bash

dialog=$(which dialog)
if [ x$dialog == x ]
then
	echo "Please do this first:"
	echo "Redhat/CentOS: sudo yum -y install dialog"
	echo "Ubuntu/Debian: sudo apt-get install dialog"
	echo "Mac:           brew install dialog"
	exit 1
fi

md5=$(if [ `uname` == Darwin ] ; then echo md5 ; else echo md5sum ; fi)

siteUserAdmin_user="$1"
siteUserAdmin_pass="$2"
dbUser_user="$3"
dbUser_pass="$4"
dbName="$5"
role="$6"
okDirectly="$7"
if [ x"$siteUserAdmin_user" == x ]
then
	siteUserAdmin_user=siteUserAdmin
fi
if [ x"$dbUser_pass" == x ]
then
	dbUser_pass=$(date +"%s" | $md5 | base64)
fi
if [ x"$role" == x ]
then
	role=readWrite
fi


tmpfile=$(mktemp /tmp/XXXXXX)

if [ x"$okDirectly" != xOK ]
then

dialog --backtitle "System Administration Tool" --title "Create Mongo Database and DB user" \
--form "\n* siteUserAdmin is for login, if login is not needed:\n  set both siteUserAdmin & siteUserAdmin to empty\n* Will create DB user (password is randomly generated)\n* Will create DB name" 25 70 16 \
"siteUserAdmin(user):" 1 1 "$siteUserAdmin_user" 1 25 35 30 \
"siteUserAdmin(pass):" 2 1 "$siteUserAdmin_pass" 2 25 35 80 \
"DB user(user):" 3 1 "$dbUser_user" 3 25 35 40 \
"DB user(pass):" 4 1 "$dbUser_pass" 4 25 35 80 \
"DB name:" 5 1 "$dbName" 5 25 35 40 \
"role:" 6 1 "$role" 6 25 35 30 \
2> $tmpfile
	if [ $? -eq 0 ]
	then
		okDirectly=OK
	fi

else
	cat <<EOF > $tmpfile
$siteUserAdmin_user
$siteUserAdmin_pass
$dbUser_user
$dbUser_pass
$dbName
$role
EOF

fi

exitCode=1

if [ x"$okDirectly" == xOK ]
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

dropDB1="db.dropDatabase();"
dropDB2="use $dbName;"

if [ $dbName == "local" ]
then
	dropDB1=""
	dropDB2="use admin"
fi

	$mongo << EOF
use $dbName;
$dropDB1
$dropDB2
db.dropUser("$dbUser_user");
	db.createUser({
		user:"$dbUser_user",pwd:"$dbUser_pass",
		roles:[
			{role:"$role",db:"$dbName"}
		]
	});
EOF
	echo "$dbUser_pass" >&2
	exitCode=0
	
fi

rm -f $tmpfile

exit $exitCode  #0 - OK and created, !0 - OK was not pressed
