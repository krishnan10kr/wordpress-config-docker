# wordpress-config-docker
Docker compose to spin up wordpress with latest traefik



1) Download and Execute the script wordpress.sh

```
wget https://raw.githubusercontent.com/krishnan10kr/wordpress-config-docker/main/wordpress.sh
chmod + x wordpress.sh
sh wordpress.sh
```


It will ask  "Enter wordpress domain name"
You have to give the domain name of wordpress site. example: domain.com

It will ask  "Enter email where ssl expiration alerts should go:"
You have to give the email address to which ssl expiration alerts should be send.



After execution of script, all the containers are created
Containers:

```
wordpress  - wordpress php files
traefik  - Load balancer . You can access via https://lb.domain.com/(replace domain.com with your actual website name) . Logins in /root/compose/.env
wp-db -- Wordpress db
compose_wp-phpmyadmin_1 - Phpmyadmin . You can access via https://domain.com/phpmyadmin/ (replace domain.com with your actual website name) . Logins in /root/compose/.env 
compose_watchtower_1
```


The file /root/compose/.env will have all the logins needed.

