pipeline {
    agent any
    
    environment {
        DOCKER_IMAGE = 'react-nginx-app'
        DOCKER_TAG = 'latest'
        CONTAINER_NAME = 'react-nginx-container'
        REPO_URL = 'https://github.com/jksoam/re-code.git'
    }

    stages {
        stage('Clone Repository') {
            steps {
                script {
                    // Clone and clean the workspace
                    checkout scm
                    sh 'rm -rf build || true'
                }
            }
        }

        stage('Install and Build React App') {
            steps {
                script {
                    // Install dependencies and build React app
                    sh '''
                    npm install
                    npm run build
                    '''
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    // Build Docker image with NGINX
                    sh '''
                    docker build -t $DOCKER_IMAGE:$DOCKER_TAG .
                    '''
                }
            }
        }

        stage('Stop and Remove Old Container') {
            steps {
                script {
                    // Stop and remove old container if running
                    sh '''
                    docker stop $CONTAINER_NAME || true
                    docker rm $CONTAINER_NAME || true
                    '''
                }
            }
        }

        stage('Run New Docker Container') {
            steps {
                script {
                    // Run new container with NGINX and React
                    sh '''
                    docker run -d -p 8080:80 --name $CONTAINER_NAME $DOCKER_IMAGE:$DOCKER_TAG
                    '''
                }
            }
        }
    }

    post {
        success {
            echo '✅ Deployment successful! App is running on port 80.'
        }
        failure {
            echo '❌ Deployment failed. Check logs for errors.'
        }
    }
}
