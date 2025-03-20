pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'react-nginx-app'
        DOCKER_TAG = 'latest'
        CONTAINER_NAME = 'react-nginx-container'
        REPO_URL = 'https://github.com/jksoam/re-code.git'
        REMOTE_HOST = '54.242.109.3'
        REMOTE_USER = 'root'
        APP_PATH = '/root/app'
    }

    stages {
        stage('Clone Repository') {
            steps {
                script {
                    // Clone repo and clean old build
                    checkout scm
                    sh 'rm -rf build || true'
                }
            }
        }

        stage('Install and Build React App') {
            steps {
                script {
                    sh '''
                    set -x  # Debugging enable
                    npm install
                    npm run build
                    set +x  # Debugging disable
                    '''
                }
            }
        }

        stage('Transfer Build to Remote') {
            steps {
                script {
                    withCredentials([sshUserPrivateKey(credentialsId: 'docker_vm_ssh_key', keyFileVariable: 'SSH_KEY')]) {
                        sh '''
                        ssh -i $SSH_KEY -o StrictHostKeyChecking=no $REMOTE_USER@$REMOTE_HOST "rm -rf $APP_PATH/build"
                        scp -i $SSH_KEY -o StrictHostKeyChecking=no -r build/ $REMOTE_USER@$REMOTE_HOST:$APP_PATH/build
                        '''
                    }
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    withCredentials([sshUserPrivateKey(credentialsId: 'docker_vm_ssh_key', keyFileVariable: 'SSH_KEY')]) {
                        sh '''
                        ssh -i $SSH_KEY -o StrictHostKeyChecking=no $REMOTE_USER@$REMOTE_HOST << EOF
                        cd $APP_PATH
                        docker build --no-cache -t $DOCKER_IMAGE:$DOCKER_TAG .
                        EOF
                        '''
                    }
                }
            }
        }

        stage('Deploy Container with Zero Downtime') {
            steps {
                script {
                    withCredentials([sshUserPrivateKey(credentialsId: 'docker_vm_ssh_key', keyFileVariable: 'SSH_KEY')]) {
                        sh '''
                        ssh -i $SSH_KEY -o StrictHostKeyChecking=no $REMOTE_USER@$REMOTE_HOST << EOF
                        docker run -d --rm -p 8080:80 --name temp_container $DOCKER_IMAGE:$DOCKER_TAG
                        docker stop $CONTAINER_NAME || true
                        docker rm $CONTAINER_NAME || true
                        docker rename temp_container $CONTAINER_NAME
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
