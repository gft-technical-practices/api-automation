node {
    try {
        notifyBuild('STARTED')
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
    } catch (e) {
        // If there was an exception thrown, the build failed
        currentBuild.result = "FAILED"
        throw e
    } finally {
        // Success or failure, always send notifications
        notifyBuild(currentBuild.result)
    }
}

def notifyBuild(String buildStatus = 'STARTED') {
  // build status of null means successful
  buildStatus =  buildStatus ?: 'SUCCESSFUL'

  // Default values
  def colorName = 'RED'
  def colorCode = '#FF0000'
  def subject = "${buildStatus}: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'"
  def summary = "${subject} (${env.BUILD_URL})"
  def details = """<p>STARTED: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]':</p>
    <p>Check console output at &QUOT;<a href='${env.BUILD_URL}'>${env.JOB_NAME} [${env.BUILD_NUMBER}]</a>&QUOT;</p>"""

  // Override default values based on build status
  if (buildStatus == 'STARTED') {
    color = 'YELLOW'
    colorCode = '#FFFF00'
  } else if (buildStatus == 'SUCCESSFUL') {
    color = 'GREEN'
    colorCode = '#00FF00'
  } else {
    color = 'RED'
    colorCode = '#FF0000'
  }

  // Send notifications
  slackSend (color: colorCode, message: summary)
}