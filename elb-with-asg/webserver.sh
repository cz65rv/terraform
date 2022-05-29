#! /bin/bash
sudo apt-get update -y
sudo apt install nginx -y 
echo "<html> <h1> Hello, World from host   $HOSTNAME </h1> </html>" > /var/www/html/index.nginx-debian.html
systemctl restart nginx