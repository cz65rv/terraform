#! /bin/bash
#Install default JRE required for Jenkins
sudo apt-get update -y    
sudo apt install default-jre -y

#Install docker packages
sudo apt install docker.io -y

#Install Jenkins server
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
sudo sh -c 'echo deb https://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'  
sudo apt-get update -y
sudo apt-get install jenkins -y

#Add jenkins user to docker group
sudo usermod -aG docker jenkins

#Install AWS CLI
sudo apt install awscli -y

#Install kubectl utility
curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x ./kubectl && sudo mv ./kubectl /usr/local/bin