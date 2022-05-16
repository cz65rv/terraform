#! /bin/bash
sudo apt-get update -y
sudo apt-get install apache2 -y
sudo systemctl start apache2.service
sudo systemctl enable apache2.service
sudo chmod 777 /var/www/html/index.html
curl -s http://169.254.169.254/latest/dynamic/instance-identity/document > /var/www/html/index.html