#!/bin/bash

# Pre Reqs
apt-get update
apt-get upgrade
apt-get install git docker docker-compose openjdk-8-jdk maven awscli jq

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

# Jenkins Configuration
chown root:jenkins -R /usr/bin/node
chown root:jenkins -R /usr/local/lib/node_modules
usermod -a -G jenkins $USER

# Add the jenkins user to the docker group. Permission to create images
usermod -a -G docker jenkins

# Starting and Making Jekins on Startup Default
systemctl start jenkins
systemctl enable jenkins
systemctl status jenkins

## AWS e Docker
su - ${USER} -c 'aws configure'
su - jenkins -c 'docker login'

# Aws files permissioins for jenkins user
chown ${USER}:jenkins -R ~/.aws
chmod -R g=u ~/.aws

## Reiniciando
systemctl restart jenkins

# APIs base docker images
systemctl restart docker
docker pull node:alpine
