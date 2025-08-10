pipeline {
    agent any
    
    stages {
        stage('Without docker') {
            steps {
                sh '''
                echo "Hello World"
                touch nocontainer.txt
                  ls -la
                '''
            }
        }
        stage('With docker') {
            agent { 
                docker {
                    image 'node:18-alpine'
                    reuseNode true
                }
            }
            steps {
                sh '''
                echo "Hello With Docker"
                npm -v
                ls -la
                  touch container.txt
                '''
            }
        }    
    }
}