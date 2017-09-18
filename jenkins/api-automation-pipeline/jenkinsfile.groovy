node {
    try {
        notifyBuild('STARTED')
        
        stage('Preparation') {
            
            // Clean Workspace
            cleanWs()
            
            // Get some code from a GitHub repository
            git "${env.REPO_URL}"

            // Permission to execute
            sh "chmod +x -R ${env.WORKSPACE}/../${env.JOB_NAME}@script/jenkins/api-automation-pipeline"

            // Convert Swagger Definition from YAML to JSON
            sh "${env.WORKSPACE}/../${env.JOB_NAME}@script/jenkins/api-automation-pipeline/convert_yaml_json.sh"    
        }

        stage('Scaffolding') {
            // Run scripts to scaffolding the project
            withEnv(['NODE_PATH=/usr/local/lib/node_modules']) {
                sh "${env.WORKSPACE}/../${env.JOB_NAME}@script/jenkins/api-automation-pipeline/scaffolding.sh"
            }
            
            // Clean
            sh "${env.WORKSPACE}/../${env.JOB_NAME}@script/jenkins/api-automation-pipeline/clean.sh"
        }

        stage('Build') {
            docker.withRegistry('https://registry.hub.docker.com', 'dockerhub') {
                def customImage = docker.build("rmzoni/${env.API_NAME}:${env.BUILD_ID}")
                customImage.push()
            }
            
        }

        stage('Deploy') {
            withCredentials([usernamePassword(credentialsId: 'awscredential', usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY)]) {
                sh "${env.WORKSPACE}/../${env.JOB_NAME}@script/jenkins/api-automation-pipeline/deploy/deploy_ecs.sh"
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