import hudson.model.*

// Represents the current Build of Job Jenkins
def build = Thread.currentThread().executable
def gitUrl = build.environment.get("GIT_URL")


return [
    /*
        Git Hub URL has this pattern:
            - https://<dns>/<user or organization>/<repo name>/<option tree>/<optional branch or tag>
            - The API name is the repo name
    */ 
    API_NAME: gitUrl.tokenize('/')[3]
];