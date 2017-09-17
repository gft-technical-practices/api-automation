#!/bin/bash
set -x #echo on

#API_NAME="user-api"
#BUILD_NUMBER="2"
SERVICE_NAME="${API_NAME}-service"
ECS_CLUSTER=default-apiautomation

# Replacing the macros definitions in taks definition file
sed -e "s;%API_NAME%;${API_NAME};g" -e "s;%BUILD_NUMBER%;${BUILD_NUMBER};g" ./task_def_template.json > ./${API_NAME}-${BUILD_NUMBER}.json

# TODO Set Port

# Registering the task definition
aws ecs register-task-definition --cli-input-json file://${API_NAME}-${BUILD_NUMBER}.json

# Getting the task revision
TASK_REVISION=`aws ecs describe-task-definition --task-definition ${API_NAME} | jq '.taskDefinition.revision'`

# Check if the service exists
SERVICE_EXISTS=`aws ecs describe-services --cluster ${ECS_CLUSTER} --services ${SERVICE_NAME} | jq '.services[0].serviceName'`
if [ ${SERVICE_EXISTS} != null ]; then
    
    # Get the desire count instance for this service
    DESIRED_COUNT=`aws ecs describe-services --cluster ${ECS_CLUSTER} --services ${SERVICE_NAME} | jq '.services[0].desiredCount'`
    if [ ${DESIRED_COUNT} = "0" ]; then
        DESIRED_COUNT="1"
    fi

    # Update the Service definition
    aws ecs update-service --cluster ${ECS_CLUSTER} --service ${SERVICE_NAME} --task-definition ${API_NAME}:${TASK_REVISION} --desired-count ${DESIRED_COUNT}

else
    ## TODO Create Load Balancing
    # Creating the service instance. Running the docker image
    aws ecs create-service --cluster ${ECS_CLUSTER} --service-name ${SERVICE_NAME} --task-definition ${API_NAME}:${TASK_REVISION} --desired-count 1
fi  
