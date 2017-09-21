#!/bin/bash
set -x #echo on

# Convert YAML Swagger to JSON Swagger
API_FILE_NAME=`ls | grep .yaml | head -n 1`
yaml2json ./${API_FILE_NAME} --pretty > ./api.json
