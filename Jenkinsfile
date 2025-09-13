pipeline {
    agent any

    environment {
        REACT_APP_VERSION = "1.0.$BUILD_ID"
        AWS_DEFAULT_REGION = 'us-east-1'
    }

    stages {
       /* stage('Build') {
            agent {
                docker {
                    image 'node:18-alpine'
                    reuseNode true
                }
            }
            steps {
                sh '''
                    ls -la
                    node --version
                    npm --version
                    npm ci
                    npm run build
                    ls -la
                    echo "Build completed"
                '''
            }
        }
        */

        stage('deploy to aws') {
            agent {
                docker {
                    image 'amazon/aws-cli:2.28.25'
                    reuseNode true
                    args "-u root --entrypoint=''"
                }
            }

            steps {
                withCredentials([usernamePassword(credentialsId: 'aws-s3-user', passwordVariable: 'AWS_SECRET_ACCESS_KEY', usernameVariable: 'AWS_ACCESS_KEY_ID')]) {
                    // some block
                    sh '''
                aws --version
                yum install jq -y
                LATEST_TD_REVISION=$(aws ecs register-task-definition --cli-input-json file://aws/task-definition.json | jq '.taskDefinition.revision')
                echo $LATEST_TD_REVISION
                aws ecs update-service --cluster tolu-learnjenkins-app --service tolu-learnjenkinsapp-service-prod --task-definition tolu-learnjenkinsapp-taskdefinitionprod:$LATEST_TD_REVISION
                '''
                }
            }
        }

/*
        stage('Approval') {
            steps {
                timeout(time: 15, unit: 'MINUTES') {
                    input message: 'Do you wish to deploy to production ?', ok: 'Yes I am sure'
                    sh 'echo "This is Approval Stage"'
                }
            }
        }
*/

    }
}
