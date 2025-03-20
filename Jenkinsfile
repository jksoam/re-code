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
                    // Clone repo and clean
                    checkout scm
                    sh 'rm -rf build || true'
                }
            }
        }

        stage('Install and Build React App') {
            steps {
                script {
                    // Install and build
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
                    // Transfer build folder to Docker VM and build image
                    sshagent(['docker_vm_ssh_key']) {
                        sh '''
                        scp -r build/ root@54.242.109.3:/root/app/build
                        ssh root@54.242.109.3 << EOF
                        cd /root/app
                        docker build -t $DOCKER_IMAGE:$DOCKER_TAG .
                        EOF
                        '''
                    }
                }
            }
        }

        stage('Stop and Remove Old Container') {
            steps {
                script {
                    // Stop and remove old container
                    sshagent(['docker_vm_ssh_key']) {
                        sh '''
                        ssh root@54.242.109.3 << EOF
                        docker stop $CONTAINER_NAME || true
                        docker rm $CONTAINER_NAME || true
                        EOF
                        '''
                    }
                }
            }
        }

        stage('Run New Docker Container') {
            steps {
                script {
                    // Run new container
                    sshagent(['docker_vm_ssh_key']) {
                        sh '''
                        ssh root@54.242.109.3 << EOF
                        docker run -d -p 80:80 --name $CONTAINER_NAME $DOCKER_IMAGE:$DOCKER_TAG
                        EOF
                        '''
                    }
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
