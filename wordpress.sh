#!/bin/sh

## Install docker-ce and docker-compose

yum install -y yum-utils
yum-config-manager --enable extras
yum install -y device-mapper-persistent-data lvm2
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum install -y docker-ce docker-ce-cli containerd.io
curl -L "https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

systemctl start docker
systemctl enable docker

## Create directories and retrieve configuration files.

mkdir -p /root/compose/files/config
curl -fsSL https://raw.githubusercontent.com/krishnan10kr/wordpress-config-docker/main/docker-compose.yml -o /root/compose/docker-compose.yml
curl -fsSL https://raw.githubusercontent.com/krishnan10kr/wordpress-config-docker/main/.env -o /root/compose/.env
curl -fsSL https://raw.githubusercontent.com/krishnan10kr/wordpress-config-docker/main/php.ini -o /root/compose/php.ini
curl -fsSL https://raw.githubusercontent.com/krishnan10kr/wordpress-config-docker/main/files/traefik.yml  -o /root/compose/files/traefik.yml
curl -fsSL https://raw.githubusercontent.com/krishnan10kr/wordpress-config-docker/main/files/acme.json -o /root/compose/files/acme.json
curl -fsSL https://raw.githubusercontent.com/krishnan10kr/wordpress-config-docker/main/files/config/dynamic.yml -o /root/compose/files/config/dynamic.yml


read -p "Enter wordpress domain name: " website
read -p "Enter email where ssl expiration alerts should go: " acmemail
sed -i -e "s|"admin@yourdomain"|$acmemail|g" /root/compose/files/traefik.yml
sed -i -e "s|^TRAEFIK_DOMAINS=.*|TRAEFIK_DOMAINS=lb.`echo $website`|" /root/compose/.env
sed -i -e "s|^WORDPRESS_DOMAINS=.*|WORDPRESS_DOMAINS=`echo $website`|" /root/compose/.env
sed -i -e "s|^WORDPRESS_DB_ROOT_PASSWORD=.*|WORDPRESS_DB_ROOT_PASSWORD=`cat /dev/urandom | tr -dc '[:alnum:]' | head -c14`|" /root/compose/.env
sed -i -e "s|^WORDPRESS_DB_PASSWORD=.*|WORDPRESS_DB_PASSWORD=`cat /dev/urandom | tr -dc '[:alnum:]' | head -c14`|" /root/compose/.env

sed -i -e "s|^WORDPRESS_DB_NAME=.*|WORDPRESS_DB_NAME=wordpress_`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1`|" /root/compose/.env

sed -i -e "s|^WORDPRESS_DB_USER=.*|WORDPRESS_DB_USER=wordpress_`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1`|" /root/compose/.env

yum install -y httpd-tools -y
BASIC_AUTH_PASSWORD="`cat /dev/urandom | tr -dc '[:alnum:]' | head -c10`"
BASIC_AUTH="`printf '%s\n' "$BASIC_AUTH_PASSWORD" | tee /root/compose/http-auth.txt | htpasswd -in admin`"
sed -i -e "s|^BASIC_AUTH=.*|BASIC_AUTH=$BASIC_AUTH|" /root/compose/.env


## file for traefik to store keys and certs
touch /root/compose/files/acme.json
chmod 600 /root/compose/files/acme.json

## creating public network
docker network create frontend

## Start our containers.
cd /root/compose
docker-compose up -d

