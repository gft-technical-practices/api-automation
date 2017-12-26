# API Automation

This repository maintains code to demonstrate a API Automation Flow using AWS ECS.

## Pre Requirements

### AWS Pre Requirements
[Create a new IAM role](http://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_create_for-service.html) (e.g. ecs-service-role), select the Amazon EC2 Container Service Role type and attach the AmazonEC2ContainerServiceRole policy. This will allows ECS to create and manage AWS resources, such as an ELB, on your behalf.

Follow the [Setting Up with Amazon ECS](http://docs.aws.amazon.com/AmazonECS/latest/developerguide/get-set-up-for-amazon-ecs.html) guide to get ready to use ECS. If you haven’t done so yet, make sure to start [at least one container instance](http://docs.aws.amazon.com/AmazonECS/latest/developerguide/ECS_GetStarted.html#getting_started_launch_container_instance) in your account and create the Amazon ECS service role in the AWS IAM console.

Launch an Amazon EC2 instance using the Amazon Linux AMI and install and configure the required packages. Make sure that the security group you select for your instance allows traffic on ports TCP/22 and TCP/8080.

#### IAM User for AWS CLI
A user with access to ECS trhough AWS CLI is going to be required:
- The user must have an AWS Access Key
- The user must have these policies permissions:
  - AmazonEC2ContainerRegistryReadOnly
  - AmazonEC2ContainerServiceEventsRole
  - AmazonEC2ContainerServiceAutoscaleRole
  - AmazonEC2ContainerRegistryFullAccess
  - AmazonEC2ContainerServiceFullAccess
  - AmazonEC2ContainerRegistryPowerUser
  - AmazonEC2ContainerServiceforEC2Role
  - AmazonEC2ContainerServiceRole

#### EC2 Container Service - Cluster
A ECS Cluster must be create with these following constraints
- [ECS Cluster Name](http://docs.aws.amazon.com/AmazonECS/latest/developerguide/create_cluster.html): default

#### ECS Container Service - Swagger CodeGen Instance
A [task definition must be create](http://docs.aws.amazon.com/AmazonECS/latest/developerguide/create-task-definition.html) for the Swagger CodeGen Docker Instance:
```javascript
{
  "requiresAttributes": [],
  "taskDefinitionArn": "arn:aws:ecs:us-east-1:940925175528:task-definition/swagger-codegen-app-static:3",
  "networkMode": "bridge",
  "status": "ACTIVE",
  "revision": 3,
  "taskRoleArn": null,
  "containerDefinitions": [
    {
      "volumesFrom": [],
      "memory": 300,
      "extraHosts": null,
      "dnsServers": null,
      "disableNetworking": null,
      "dnsSearchDomains": null,
      "portMappings": [
        {
          "hostPort": 8000,
          "containerPort": 8080,
          "protocol": "tcp"
        }
      ],
      "hostname": null,
      "essential": true,
      "entryPoint": [],
      "mountPoints": [],
      "name": "swagger-codegen-app",
      "ulimits": null,
      "dockerSecurityOptions": null,
      "environment": [],
      "links": [],
      "workingDirectory": null,
      "readonlyRootFilesystem": null,
      "image": "swaggerapi/swagger-generator",
      "command": [],
      "user": null,
      "dockerLabels": null,
      "logConfiguration": null,
      "cpu": 10,
      "privileged": null,
      "memoryReservation": null
    }
  ],
  "placementConstraints": [],
  "volumes": [],
  "family": "swagger-codegen-app-static"
}
```

A [service must be create](http://docs.aws.amazon.com/AmazonECS/latest/developerguide/create-service.html) using the previous service defition:
- Service Name: swagger-codegen-webapp
- Task Defition:  swagger-codegen-app-static
- Desired count: 1
- Service Role: ecsServiceRole

### Jenkins Prequirements
To install and configure the Jenkins plugins required to build a Docker image and publish it to a Docker registry (DockerHub in our case). We’ll also need a plugin to interact with the code repository of our choice, GitHub in our case.
 
From the Jenkins dashboard select Manage Jenkins and click Manage Plugins. On the Available tab, search for and select the following plugins:
- [Slack Notification Plugin](https://plugins.jenkins.io/slack)
- [Github plugin](https://wiki.jenkins.io/display/JENKINS/Github+Plugin)
- [Generic Webhook Trigger Plugin](https://wiki.jenkins.io/display/JENKINS/Generic+Webhook+Trigger+Plugin)

Configuration:
- CORS must be disable for Jenkins API (Alow GitHub WebHook)
- A "dockerhub" credential must be create to access docker hub registry
- Global Slack Notifier Setting must be configurated
  - A slack token must bu issued. [Slack Legacy Tokens](https://api.slack.com/custom-integrations/legacy-tokens)

### Docker Hub
A Docker Hub account must be create. The user and password will be requested by the config.sh script.

## Tools
The tools used for this project are:
- Swagger CodeGen Docker Image
- AWS EC2 Container Service
- Docker
- Custom API-Scaffolding (Node.JS Application)
- Jenkins 2.0


## Git Hub Organization - API Design
An organization was created in GitHub to centralized the repositories that are going to keep the API contracts written in Swagger 2.0.

The organization is [API Design Automation](https://github.com/orgs/api-design-automation/dashboard).

This organization has a configured webhook to start the api-automation-pipeline as Jenkins Job.

## Jenkins Machine Configuration
Follow the intstruction in a Ubuntu Linux Machine to configure the Jenkins Environment:
- Install Git
```sh
sudo apt-get install git
```
- Clone this project
```sh
git clone https://github.com/gft-technical-practices/api-automation
```
- Run the the Environment Configuration Script
```sh
cd api-automation/env
sudo ./config.sh
```
  - Some manual configuration is going to be required
  - Configura Docker Login
  - Configure AWS Credetials for AWS CLI usage

- Configure Jenkins
  - Set Adm Password located in /var/lib/jenkins/secrets/initialAdminPassword
  - Install Selected Plugins (Commons)
  - Configure an Admistrator User

- Configure Docker Credential in Jenkins
  - Create username / password credential to docker hub registry with this name "dockerhub"

- Configure AWS Credential in Jenkins
  - Create username / password credential to AWS User Access Key with this name "awscredential"

- Configure Jenkins for Slack Notification
  - Install Slack Notification Plugin
  - Create a secret text credential using the an slack legacy token named "slacktoken"
  - In the system configuration configure the global slack notification setting

- Create the API Automation Pipeline
  - Create a new job names "api-automation"
  - This job must be a pipeline
  - Create a parametrized job
    - REPO_URL - GIT Repository URL
      - $.repository.clone_url
    - API_NAME - The Repository Name as the API Name
      - $.repository.name
    - TAG_NAME - The name of the tag
      - $.ref
  - Set a Generic Webhook Trigger
  - Configure the job to allows remotely builds
  - Set the pipeline to use a SCM
    - Use Git
    - Configure the repo as https://github.com/gft-technical-practices/api-automation
    - The script path must be ./jenkins/api-automation-pipeline/jenkinsfile.groovy
    - The Lightweight checkout must be unchecked

- Configure a GitHub Webhook
  - In the github project or a github organization a webhook must be configure to start the jenkins job
  - The webhook must be emit from a tag creation

## API Automation Pipeline
The API Automation pipeline objective is to receive a an WebHook Tag Creation event, this event contains the a API Swagger file definition in git repository.

After receiving the event the job:
- Scaffoldes the project from the API Swagger definition file
- Create a docker image from this new scaffolded project
- Publish a new docker instance to the AWS ECS

### Preparation
- Clean the Workspace
- Git clone the current tag
- Convert the API Swagger YAML to JSON

### Scaffolding
- Create a Node.JS Scaffolded project

### Build
- Build a docker Node.JS image from the scaffolded project
- Publish this image to the Docker Hub Registry

### Deploy
- Create new task definition revision in AWS ECS
- Verifies if a service definition exists
-- If exists, update to the new task revision
-- If not exists, create a new service definition using the current task revision