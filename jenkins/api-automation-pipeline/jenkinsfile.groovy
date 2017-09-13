node {

   stage('Preparation') {
      
      // Clean Workspace
      cleanWs()
      
      // Get some code from a GitHub repository
      git "${env.REPO_URL}"

      // Convert Swagger Definition from YAML to JSON
      sh '''#!/bin/bash

            # Convert YAML Swagger to JSON Swagger
            yaml2json ./api.yaml --pretty > ./api.json
        '''    
   }

   stage('Scaffolding') {
       // Run scripts to scaffolding the project
       withEnv(['NODE_PATH=/usr/local/lib/node_modules']) {
            sh '''#!/usr/bin/env node
            const shell = require(\'shelljs\');
            const swg = require(\'api-scaffolding\');
            const fs = require(\'fs-extra\');
            const path = require(\'path\');
            const asciify = require(\'asciify\');

            const spec = fs.readJsonSync(path.resolve(\'./api.json\'));

            // Criando as apis na versão server
            shell.echo(swg.createServer(spec, \'nodejs-server\'));


            asciify(\'Scaffolding\', {font:\'small\'}, (err, res) => {shell.echo(res)});
            asciify(\'Create APIs\', {font:\'standard\', color: \'blue\'}, (err, res) => {shell.echo(res)});
          '''
       }
       

        // Clean
        sh '''#!/bin/bash
                mv ${WORKSPACE}/nodejs-server-server/* ${WORKSPACE}
                rm -rf ${WORKSPACE}/nodejs-server-server
                rm -rf ${WORKSPACE}/download
            '''

   }

   stage('Build') {
       docker.withRegistry('https://registry.hub.docker.com', 'dockerhub') {
            def customImage = docker.build("rmzoni/${env.API_NAME}:${env.BUILD_ID}")
            customImage.push()
       }
       
   }
}