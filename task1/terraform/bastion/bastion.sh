#!/bin/bash

sudo yum update -y
sudo yum install nginx
#
#sudo -i
#sudo cat > /etc/nginx/conf.d/ldap.conf << EOF
#server {
#      listen 80;
#      server_name 107.21.168.251;
#      location / {
#          proxy_pass http://10.0.10.51/phpldapadmin;
#      }
#   }
#EOF
#
