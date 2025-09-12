pipeline {
    agent any

    environment {
        REACT_APP_VERSION = "1.0.$BUILD_ID"
        AWS_DEFAULT_REGION = 'eu-west-3'
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
                    args "--entrypoint=''"
                }
            }

            steps {
                withCredentials([usernamePassword(credentialsId: 'aws-s3-user', passwordVariable: 'AWS_SECRET_ACCESS_KEY', usernameVariable: 'AWS_ACCESS_KEY_ID')]) {
                    // some block
                    sh '''
                aws --version
                aws ecs register-task-definition --cli-input-json file://aws/task-definition.json
                '''
                }
            }
        }

        stage('Approval') {
            steps {
                timeout(time: 15, unit: 'MINUTES') {
                    input message: 'Do you wish to deploy to production ?', ok: 'Yes I am sure'
                    sh 'echo "This is Approval Stage"'
                }
            }
        }

    }
}
