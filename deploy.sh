#!/bin/bash

apt-get update -y && apt-get upgrade -y
apt-get install sudo vim ufw portsentry fail2ban apache2 mailutils -y

sudo useradd -p $(openssl passwd -1 123) roger
sudo adduser roger sudo

sudo rm -rf /etc/network/interfaces
sudo cp ./assets/interfaces /etc/network/
sudo cp ./assets/enp03s /etc/network/interfaces.d/

sudo service networking restart

sudo rm -rf /etc/ssh/sshd_config
sudo cp ./assets/sshd_config /etc/ssh/

sudo yes "y" | ssh-keygen -q -N "" > /dev/null
sudo mkdir ~/.ssh
sudo cat ./assets/id_rsa.pub > ~./ssh/authorized_keys

sudo service sshd restart

sudo rm -rf /etc/fail2ban/jail.conf
sudo cp ./assets/jail.conf /etc/fail2ban/

sudo service fail2ban restart

sudo ufw allow 50683/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443
sudo ufw enable

sudo rm -rf /etc/default/portsentry
sudo cp ./assets/portsentry /etc/default/
sudo rm -rf /etc/portsentry/portsentry.conf
sudo cp ./assets/portsentry.conf /etc/portsentry
sudo service portsentry restart

sudo systemctl disable console-setup.service
sudo systemctl disable keyboard-setup.service
sudo systemctl disable apt-daily.timer
sudo systemctl disable apt-daily-upgrade.timer
sudo systemctl disable syslog.service

sudo cp ./assets/update.sh ~/
sudo rm -rf /var/spool/cron/crontabs
sudo cp -r ./assets/crontabs /var/spool/cron

sudo cp ./assets/cron_monitor.sh ~/

sudo chmod 777 ~/cron_monitor.sh
sudo chmod 777 ~/update.sh

sudo systemctl enable cron

sudo cp -r ./assets/html /var/www/

sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -subj "/C=FR/ST=IDF/O=42/OU=Project-roger/CN=192.168.22.247" -keyout /etc/ssl/private/apache-selfsigned.key -out /etc/ssl/certs/apache-selfsigned.crt

sudo rm -rf /etc/apache2/conf-available/ssl-params.conf
sudo cp ./assets/ssl-params.conf /etc/apache2/conf-available/

sudo rm -rf /etc/apache2/sites-available/default-ssl.conf
sudo cp ./assets/default-ssl.conf /etc/apache2/sites-available/

sudo rm -rf /etc/apache2/sites-available/000-default.conf
sudo cp ./assets/000-default.conf /etc/apache2/sites-available

sudo a2enmod ssl
sudo a2enmod headers
sudo a2ensite default-ssl
sudo a2enconf ssl-params
systemctl reload apache2

