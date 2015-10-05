#!/bin/bash

scriptPath=$(cd `dirname $0`; pwd)

if [ $UID -ne 0 ]
then
	echo "Use \"sudo\" to run this, or switch to root to run this."
	exit 1
fi


sudo touch /var/log/installserver.log
sudo chmod 666 /var/log/installserver.log

section="# ----- [ Git-key ] ----- #"
echo "$section"

#==== gitkey ====#
sudo touch /usr/bin/gitkey.sh
sudo chmod a+w /usr/bin/gitkey.sh
cat <<EOF > /usr/bin/gitkey.sh
#!/bin/bash

# The MIT License (MIT)
# Copyright (c) 2013 Alvin Abad

if [ \$# -eq 0 ]; then
    echo "Git wrapper script that can specify an ssh-key file
Usage:
    gitkey.sh -i ssh-key-file git-command
    "
    exit 1
fi

# remove temporary file on exit
trap 'rm -f /tmp/.git_ssh.\$\$' 0

if [ "\$1" = "-i" ]; then
    SSH_KEY=\$2; shift; shift
    echo "ssh -i \$SSH_KEY \\\$@" > /tmp/.git_ssh.\$\$
    chmod +x /tmp/.git_ssh.\$\$
    export GIT_SSH=/tmp/.git_ssh.\$\$
fi

# in case the git command is repeated
[ "\$1" = "git" ] && shift

# Run the git command
git "\$@"
EOF
sudo chmod 755 /usr/bin/gitkey.sh


