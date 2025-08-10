pipeline {
    agent any

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
                node -v
                npm -v
                npm ci
                npm run build
                ls -la
                echo "This is build stage"

                '''
            }
        }
        stage('Test') {
            agent {
                docker {
                    image 'node:18-alpine'
                    reuseNode true
                }
            }
            steps {
                sh '''
            npm test
            ls -la
            ls -l build | grep index.html
            echo "This is Test Stage"
            echo "Success"

            '''
            }

        }

        stage('Explore Stage') {
            agent {
                docker {
                    image 'node:18-alpine'
                    reuseNode true
                }
            }

            steps {
                sh '''
                echo "I am only testing my ability to add another stage"
                '''
            }
        }

        stage('E2E ') {
            agent {
                docker {
                    image 'mcr.microsoft.com/playwright:v1.54.0-noble'
                    reuseNode true
                }
            }

            steps {
                sh '''
               npm install -g serve
               serve -s build
               npx playwright test
                '''
            }
        }


    }

    post {
        always {
            junit 'test-results/junit.xml'
        }
    }


}