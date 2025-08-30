pipeline {
    agent any

    environment {
        NETLIFY_SITE_ID = '6ee338b1-b7ec-4467-aa80-e8f9bce811b7'
        NETLIFY_AUTH_TOKEN = credentials('netlify-token')
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
                    npm run build
                    ls -la
                    echo "Build completed"
                '''
            }
        }

        stage('Tests') {
            parallel {
                stage('Unit Tests') {
                    agent {
                        docker {
                            image 'node:18-alpine'
                            reuseNode true
                        }
                    }
                    steps {
                        sh 'npm test'
                    }
                    post {
                        always {
                            junit 'jest-results/junit.xml'
                        }
                    }
                }

                stage('E2E') {
                    agent {
                        docker {
                            image 'mcr.microsoft.com/playwright:v1.54.2-jammy'
                            reuseNode true
                        }
                    }
                    steps {
                        sh '''
                            npm install serve
                            node_modules/.bin/serve -s build &
                            sleep 10
                            npx playwright test --reporter=html
                        '''
                    }
                    post {
                        always {
                            publishHTML([
                                reportDir: 'playwright-report',
                                reportFiles: 'index.html',
                                reportName: 'Playwright Local'
                            ])
                        }
                    }
                }
            }
        }

        stage('Deploy to Staging') {
            agent {
                docker {
                    image 'node:18'
                    reuseNode true
                }
            }
            steps {
                sh '''
                    npm install netlify-cli node-jq
                    echo "Deploying to staging. Site ID: $NETLIFY_SITE_ID"
                    npx netlify deploy --dir=build --json > deploy-output.json
                '''
                script {
                    env.STAGING_URL = sh(
                        script: "npx jq -r '.deploy_url' deploy-output.json",
                        returnStdout: true
                    ).trim()
                    echo "Staging URL: ${env.STAGING_URL}"
                }
            }
        }

        stage('Staging E2E') {
            agent {
                docker {
                    image 'mcr.microsoft.com/playwright:v1.54.2-jammy'
                    reuseNode true
                }
            }
            steps {
                sh '''
                    echo "Running E2E tests against staging: $STAGING_URL"
                    npx playwright test --reporter=html
                '''
            }
            post {
                always {
                    publishHTML([
                        reportDir: 'playwright-report',
                        reportFiles: 'index.html',
                        reportName: 'Playwright Staging'
                    ])
                }
            }
        }

        stage('Approval') {
            steps {
                timeout(time: 15, unit: 'MINUTES') {
                    input message: 'Do you wish to deploy to production?', ok: 'Yes, I am sure'
                }
                sh 'echo "Approval granted. Proceeding to Production deployment."'
            }
        }

        stage('Deploy to Prod') {
            agent {
                docker {
                    image 'node:18'
                    reuseNode true
                }
            }
            steps {
                sh '''
                    npm install netlify-cli
                    echo "Deploying to production. Site ID: $NETLIFY_SITE_ID"
                    npx netlify deploy --dir=build --prod
                '''
            }
        }

        stage('Prod E2E') {
            agent {
                docker {
                    image 'mcr.microsoft.com/playwright:v1.54.2-jammy'
                    reuseNode true
                }
            }
            environment {
                CI_ENVIRONMENT_URL = 'https://lighthearted-bavarois-c77534.netlify.app'
            }
            steps {
                sh '''
                    echo "Running E2E tests against production: $CI_ENVIRONMENT_URL"
                    npx playwright test --reporter=html
                '''
            }
            post {
                always {
                    publishHTML([
                        reportDir: 'playwright-report',
                        reportFiles: 'index.html',
                        reportName: 'Playwright Prod'
                    ])
                }
            }
        }
    }
}
