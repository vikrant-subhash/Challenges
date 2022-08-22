#!/bin/bash
while ! yum update -y
do
    echo 'waiting for internet connection...'
    sleep 2
done
yum install -y httpd git
git clone https://github.com/gabrielecirulli/2048.git
cp -R 2048/* /var/www/html/
systemctl start httpd && systemctl enable httpd
