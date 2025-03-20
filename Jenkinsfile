pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'react-nginx-app'
        DOCKER_TAG = 'latest'
        CONTAINER_NAME = 'react-nginx-container'
        REPO_URL = 'https://github.com/jksoam/re-code.git'
        REMOTE_HOST = '54.242.109.3'
        REMOTE_USER = 'ubuntu'  
        APP_PATH = '/home/ubuntu/app'  
    }

    stages {
        stage('Clone Repository') {
            steps {
                script {
                    sh '''
                    rm -rf build || true
                    if [ ! -d "app" ]; then
                        git clone $REPO_URL app
                    else
                        cd app && git pull
                    fi
                    '''
                }
            }
        }

        stage('Install and Build React App') {
            steps {
                script {
                    sh '''
                    cd app
                    npm install
                    npm run build
                    '''
                }
            }
        }

        stage('Transfer Build to Remote') {
            steps {
                script {
                    withCredentials([sshUserPrivateKey(credentialsId: 'docker_vm_ssh_key', keyFileVariable: 'SSH_KEY')]) {
                        sh '''
                        ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no $REMOTE_USER@$REMOTE_HOST "mkdir -p $APP_PATH/build && rm -rf $APP_PATH/build/*"
                        scp -i "$SSH_KEY" -o StrictHostKeyChecking=no -r app/build/ $REMOTE_USER@$REMOTE_HOST:$APP_PATH/build
                        scp -i "$SSH_KEY" -o StrictHostKeyChecking=no app/Dockerfile $REMOTE_USER@$REMOTE_HOST:$APP_PATH/  # ✅ Dockerfile Copy Added
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
                        ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no $REMOTE_USER@$REMOTE_HOST << EOF
                        cd $APP_PATH
                        sudo docker build --no-cache -t $DOCKER_IMAGE:$DOCKER_TAG .
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
                        ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no $REMOTE_USER@$REMOTE_HOST << EOF
                        sudo docker stop $CONTAINER_NAME || true
                        sudo docker rm $CONTAINER_NAME || true
                        sudo docker run -d --rm -p 8080:80 --name $CONTAINER_NAME $DOCKER_IMAGE:$DOCKER_TAG
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
