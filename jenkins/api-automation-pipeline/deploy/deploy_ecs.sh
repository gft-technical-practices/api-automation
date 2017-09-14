#!/bin/bash
set -x #echo on

API_NAME="user-api"
BUILD_NUMBER="1"
SERVICE_NAME="user-api-service"

# Replacing the macros definitions in taks definition file
sed -e "s;%API_NAME%;${API_NAME};g" -e "s;%BUILD_NUMBER%;${BUILD_NUMBER};g" task_def_template.json > ${API_NAME}-${BUILD_NUMBER}.json

# Registering the task definition
#aws ecs register-task-definition --cli-input-json file://${API_NAME}-${BUILD_NUMBER}.json

# Getting the task revision
TASK_REVISION=`aws ecs describe-task-definition --task-definition ${API_NAME} | jq '.taskDefinition.revision'`
#DESIRED_COUNT=`aws ecs describe-services --services ${SERVICE_NAME} | egrep "desiredCount" | tr "/" " " | awk '{print $2}' | sed 's/,$//'`
#if [ ${DESIRED_COUNT} = "0" ]; then
#    DESIRED_COUNT="1"
#fi

# TODO - Check if the service exists

# Creating the service instance. Running the docker image
#aws ecs create-service --cluster default-apiautomation --service-name ${SERVICE_NAME} --task-definition ${API_NAME}:${TASK_REVISION} --desired-count 1
