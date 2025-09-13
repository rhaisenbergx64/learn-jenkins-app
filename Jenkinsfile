pipeline {
    agent any

    environment {
        REACT_APP_VERSION = "1.0.$BUILD_ID"
        AWS_IMAGE_NAME = 'tolujenkinsappimage'
        AWS_DEFAULT_REGION = 'us-east-1'
        AWS_ECS_CLUSTER = 'tolu-learnjenkins-app'
        AWS_ECS_SERVICE_PROD = 'tolu-learnjenkinsapp-service-prod'
        AWS_TD_PROD = 'tolu-learnjenkinsapp-taskdefinitionprod'
        AWS_ECR = '891612571043.dkr.ecr.us-east-1.amazonaws.com'
    }

    stages {
        stage('Build') {
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
                    REACT_APP_VERSION=$REACT_APP_VERSION npm run build
                    ls -la
                    echo "Build completed with version: $REACT_APP_VERSION"

                '''
            }
        }

        stage('build docker image') {
            agent {
                docker {
                    image 'amazon/aws-cli:2.13.2'
                    reuseNode true
                    args "-u root -v /var/run/docker.sock:/var/run/docker.sock --entrypoint=''"

                }
            }

            steps {
                withCredentials([usernamePassword(credentialsId: 'aws-s3-user', passwordVariable: 'AWS_SECRET_ACCESS_KEY', usernameVariable: 'AWS_ACCESS_KEY_ID')]) {

                    sh '''
                    amazon-linux-extras install docker -y
                    docker build -t  $AWS_ECR/$AWS_IMAGE_NAME:$REACT_APP_VERSION .
                    docker images
                    aws ecr get-login-password | docker login --username AWS --password-stdin $AWS_ECR
                    docker push $AWS_ECR/$AWS_IMAGE_NAME:$REACT_APP_VERSION
                    '''
                }
            }
            }



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
                aws ecs update-service --cluster $AWS_ECS_CLUSTER --service $AWS_ECS_SERVICE_PROD  --task-definition $AWS_TD_PROD:$LATEST_TD_REVISION
                aws ecs wait services-stable --cluster $AWS_ECS_CLUSTER --services $AWS_ECS_SERVICE_PROD
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
