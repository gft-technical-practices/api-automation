# API Automation

This repository maintains code to demonstrate a API Automation Flow using AWS ECS.

## Pre Requirements

### AWS Pre Requirements
[Create a new IAM role](http://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_create_for-service.html) (e.g. ecs-service-role), select the Amazon EC2 Container Service Role type and attach the AmazonEC2ContainerServiceRole policy. This will allows ECS to create and manage AWS resources, such as an ELB, on your behalf.

Follow the [Setting Up with Amazon ECS](http://docs.aws.amazon.com/AmazonECS/latest/developerguide/get-set-up-for-amazon-ecs.html) guide to get ready to use ECS. If you haven’t done so yet, make sure to start [at least one container instance](http://docs.aws.amazon.com/AmazonECS/latest/developerguide/ECS_GetStarted.html#getting_started_launch_container_instance) in your account and create the Amazon ECS service role in the AWS IAM console.

Launch an Amazon EC2 instance using the Amazon Linux AMI and install and configure the required packages. Make sure that the security group you select for your instance allows traffic on ports TCP/22 and TCP/8080.

### Jenkins Prequirements
To install and configure the Jenkins plugins required to build a Docker image and publish it to a Docker registry (DockerHub in our case). We’ll also need a plugin to interact with the code repository of our choice, GitHub in our case.
 
From the Jenkins dashboard select Manage Jenkins and click Manage Plugins. On the Available tab, search for and select the following plugins:
- [CloudBees Docker Build and Publish](https://plugins.jenkins.io/docker-build-publish)
- [Github plugin](https://wiki.jenkins.io/display/JENKINS/Github+Plugin)


