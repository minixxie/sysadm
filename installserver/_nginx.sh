#!/bin/bash

scriptPath=$(cd `dirname $0`; pwd)

if [ $UID -ne 0 ]
then
	echo "Use \"sudo\" to run this, or switch to root to run this."
	exit 1
fi


sudo touch /var/log/installserver.log
sudo chmod 666 /var/log/installserver.log

section="# ----- [ Nginx ] ----- #"
echo "$section"
sudo aptitude -q -y install nginx >> /var/log/installserver.log 2>&1

sudo mkdir -p /usr/share/GeoIP && sudo wget -O /usr/share/GeoIP/GeoIP.dat.gz http://geolite.maxmind.com/download/geoip/database/GeoLiteCountry/GeoIP.dat.gz && sudo gunzip -f /usr/share/GeoIP/GeoIP.dat.gz
sudo mkdir -p /usr/share/GeoIP && sudo wget -O /usr/share/GeoIP/GeoLiteCity.dat.gz http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz && sudo gunzip -f /usr/share/GeoIP/GeoLiteCity.dat.gz

cat <<EOF | sudo tee /etc/nginx/conf.d/log_format.conf
        #GeoIP
        geoip_country /usr/share/GeoIP/GeoIP.dat;
        geoip_city /usr/share/GeoIP/GeoLiteCity.dat;

        log_format main '\$remote_addr - [\$time_local] '
                '"\$request" \$status \$bytes_sent \$request_time \$upstream_response_time'
                '"\$http_referer" "\$http_user_agent" "\$gzip_ratio" '
                '"\$geoip_region" "\$geoip_city" "\$geoip_city_country_code"';
EOF
sudo service nginx restart >> /var/log/installserver.log 2>&1
