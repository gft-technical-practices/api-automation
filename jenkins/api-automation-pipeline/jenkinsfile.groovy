node {

   stage('Preparation') {
      
      // Clean Workspace
      cleanWs()
      
      // Get some code from a GitHub repository
      git 'https://github.com/api-design-automation/user-api'

      // Convert Swagger Definition from YAML to JSON
      sh './convert_yaml_json.sh'    
   }

   stage('Scaffolding') {
       // Run scripts to scaffolding the project
       sh './jenkins/api-automation-pipeline/scaffolding.sh'

        // Clean
        sh './jenkins/api-automation-pipeline/clean.sh'

   }

   stage('Build') {
       docker.withRegistry('https://registry.hub.docker.com', 'rmzoni-dockerhub') {
            def customImage = docker.build("rmzoni/${env.API_NAME}:${env.BUILD_ID}")
            customImage.push()
       }
       
   }
}