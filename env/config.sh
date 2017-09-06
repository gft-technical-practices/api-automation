#!/bin/bash

# Pre Reqs
apt-get update
apt-get upgrade
apt-get install git docker docker-compose openjdk-8-jdk maven awscli

# Install nodejs
./install_nodejs.sh

# Install yaml2json global module
npm install -g swagger yamljs mustache asciify shelljs fs-extra

# Docker Configuration
npm install -g ../api-scaffolding

# Docker Configuration
groupadd docker
chown root:docker /var/run/docker.sock
usermod -a -G docker $USER
systemctl start docker
systemctl enable docker

# Install Jenkins
wget -q -O - https://pkg.jenkins.io/debian/jenkins-ci.org.key | apt-key add -
echo deb http://pkg.jenkins.io/debian-stable binary/ | tee /etc/apt/sources.list.d/jenkins.list
apt-get update
apt-get install jenkins

# Add the jenkins user to the docker group. Permission to create images
usermod -a -G docker jenkins

# Starting and Making Jekins on Startup Default
systemctl start jenkins
systemctl enable jenkins
systemctl status jenkins

## Configurando AWS e Docker
#su - jenkins -c 'aws configure'
su - jenkins -c 'docker login'

## Reiniciando
systemctl restart jenkins

# APIs base docker images
docker pull node:alpine
