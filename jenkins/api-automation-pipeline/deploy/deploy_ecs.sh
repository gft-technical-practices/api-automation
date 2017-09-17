#!/bin/bash
set -x #echo on

#API_NAME="user-api"
#BUILD_NUMBER="2"
SERVICE_NAME="${API_NAME}-service"
ECS_CLUSTER=default-apiautomation
REGION=us-east-1

# Replacing the macros definitions in taks definition file
sed -e "s;%API_NAME%;${API_NAME};g" -e "s;%BUILD_NUMBER%;${BUILD_NUMBER};g" ${WORKSPACE}/../${JOB_NAME}@script/jenkins/api-automation-pipeline/deploy/task_def_template.json > ${WORKSPACE}/${API_NAME}-${BUILD_NUMBER}.json

# TODO Set Port

# Registering the task definition
aws ecs register-task-definition --region ${REGION} --cli-input-json file://${WORKSPACE}/${API_NAME}-${BUILD_NUMBER}.json

# Getting the task revision
TASK_REVISION=`aws ecs describe-task-definition --region ${REGION} --task-definition ${API_NAME} | jq '.taskDefinition.revision'`

# Check if the service exists
SERVICE_EXISTS=`aws ecs describe-services --region ${REGION} --cluster ${ECS_CLUSTER} --services ${SERVICE_NAME} | jq '.services[0].status'`
if [ ${SERVICE_EXISTS} == null  || ${SERVICE_EXISTS} == "INACTIVE"]; then

    ## TODO Create Load Balancing
    # Creating the service instance. Running the docker image
    aws ecs create-service --region ${REGION} --cluster ${ECS_CLUSTER} --service-name ${SERVICE_NAME} --task-definition ${API_NAME}:${TASK_REVISION} --desired-count 1    
    
else
    
    # Get the desire count instance for this service
    DESIRED_COUNT=`aws ecs describe-services --region ${REGION} --cluster ${ECS_CLUSTER} --services ${SERVICE_NAME} | jq '.services[0].desiredCount'`
    if [ ${DESIRED_COUNT} = "0" ]; then
        DESIRED_COUNT="1"
    fi

    # Update the Service definition
    aws ecs update-service --region ${REGION} --cluster ${ECS_CLUSTER} --service ${SERVICE_NAME} --task-definition ${API_NAME}:${TASK_REVISION} --desired-count ${DESIRED_COUNT}

fi  
