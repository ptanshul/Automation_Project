#!/bin/bash
#performing update
sudo apt update -y
#check if apache is running

dpkg --get-selections | grep apache > statuschk


#install apache if not installed
cnt=`cat statuschk | wc -l`
echo $cnt
if [ $cnt -eq 0 ]
then
	echo "apache is not installed "
	echo " installing apache  "
	sudo apt install apache2 -y
else
	echo "apache is installed"
fi	


#check id apache service is enabled

sudo service apache2 status | grep "inactive" > apachestchk
cnt=`cat apachestchk | wc -l`
echo $cnt

if [ $cnt -ne 0 ]
then
        echo "apache is not running "
        echo " starting  apache  "
	sudo service apache2 start
else
        echo "apache is running"
fi

#check if apache service is running
#sudo service apache2 status

#create tar archive of access logs

timestamp=$((date '+%d%m%Y-%H%M%S') )
echo $timestamp
myname="anshul"
tar -cvf /tmp/${myname}-httpd-logs-${timestamp}.tar /var/log/apache2/*.log 
s3_bucket="upgrad-anshul"
#copy files to s3 bucket
aws s3 \
cp /tmp/${myname}-httpd-logs-${timestamp}.tar \
s3://${s3_bucket}/${myname}-httpd-logs-${timestamp}.tar
szof=`du /tmp/${myname}-httpd-logs-${timestamp}.tar | awk '{print $1}'`

echo -e "httpd-logs\t${timestamp}\t tar\t${szof}\n" >> /var/www/html/inventory.html



