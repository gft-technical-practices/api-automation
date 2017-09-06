#!/bin/bash

# Convert YAML Swagger to JSON Swagger
yaml2json ./api.yaml --pretty > ./api.json

export API_NAME=USER_API