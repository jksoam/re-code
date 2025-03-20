pipeline {
    agent any
    
    environment {
        DOCKER_IMAGE = 'react-nginx-app'
        DOCKER_TAG = 'latest'
        CONTAINER_NAME = 'react-nginx-container'
        REPO_URL = 'https://github.com/jksoam/re-code.git'
        DOCKER_VM_IP = '54.242.109.3'  // Docker VM ka IP
    }

    stages {
        stage('Clone Repository') {
            steps {
                script {
                    // Clone and clean the workspace
                    checkout([$class: 'GitSCM', branches: [[name: '*/main']], userRemoteConfigs: [[url: "$REPO_URL"]]])
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
                    // Build Docker image
                    sh '''
                    docker build -t $DOCKER_IMAGE:$DOCKER_TAG .
                    '''
                }
            }
        }

        stage('Push Docker Image to Docker VM') {
            steps {
                script {
                    // SSH to Docker VM and remove old container + run new container
                    sshagent(['docker_vm_ssh_key']) {
                        sh '''
                        scp -o StrictHostKeyChecking=no Dockerfile root@$DOCKER_VM_IP:/root/
                        scp -r -o StrictHostKeyChecking=no build root@$DOCKER_VM_IP:/root/
                        
                        ssh -o StrictHostKeyChecking=no root@$DOCKER_VM_IP << EOF
                        docker stop $CONTAINER_NAME || true
                        docker rm $CONTAINER_NAME || true
                        docker build -t $DOCKER_IMAGE:$DOCKER_TAG /root/
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
