#!/bin/bash
set -x #echo on

# Convert YAML Swagger to JSON Swagger
yaml2json ./api.yaml --pretty > ./api.json
