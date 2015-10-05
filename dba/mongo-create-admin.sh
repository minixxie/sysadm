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
okDirectly="$3"
if [ x"$siteUserAdmin_user" == x ]
then
	siteUserAdmin_user=siteUserAdmin
fi


tmpfile=$(mktemp /tmp/XXXXXX)

if [ x"$okDirectly" != xOK ]
then

dialog --backtitle "System Administration Tool" --title "Create Mongo Admin user" \
--form "\n* Please input:" 25 70 16 \
"siteUserAdmin(user):" 1 1 "$siteUserAdmin_user" 1 25 35 30 \
"siteUserAdmin(pass):" 2 1 "$siteUserAdmin_pass" 2 25 35 80 \
2> $tmpfile
	if [ $? -eq 0 ]
	then
		okDirectly=OK
	fi

else
	cat <<EOF > $tmpfile
$siteUserAdmin_user
$siteUserAdmin_pass
EOF

fi

exitCode=1

if [ x"$okDirectly" == xOK ]
then
	nonEmptyFields=$(cat $tmpfile | grep -v "^$" | wc -l)
	if [ $nonEmptyFields -lt 2 ]
	then
		printf "\x1B[31m"
		echo "ERR: Please fill all necessary fields."
		printf "\x1B[0m"
		exit 1
	fi

	siteUserAdmin_user=$(cat $tmpfile | head -n 1 | tail -n 1)
	siteUserAdmin_pass=$(cat $tmpfile | head -n 2 | tail -n 1)

	
	mongo admin << EOF
use admin
db.createUser({
		user:"$siteUserAdmin_user",pwd:"$siteUserAdmin_pass",
		roles:[
			{role:"userAdminAnyDatabase",db:"admin"}
		]
	});
EOF
	exitCode=0
	
fi

rm -f $tmpfile

exit $exitCode  #0 - OK and created, !0 - OK was not pressed
