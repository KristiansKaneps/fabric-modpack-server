pipeline {
    agent { label 'built-in' }
    
    options {
        disableConcurrentBuilds()
    }

    environment {
        SERVER_DIR = ''
    }

    stages {
        stage('Setup Minecraft Server') {
            steps {
                script {
                    withCredentials([string(credentialsId: 'MINECRAFT_FABRIC_SERVER_DIR', variable: 'SERVER_DIR')]) {
                        echo "Using Minecraft server directory: ${env.SERVRER_DIR}"
                    
                        if (!env.SERVER_DIR?.trim()) {
                            error 'SERVER_DIR is empty. Pipeline will be aborted.'
                        }
                        
                        
                        if (!fileExists(env.SERVER_DIR)) {
                            sh "mkdir -p ${env.SERVER_DIR}"
                        }
                        
                        dir(env.SERVER_DIR) {
                        }
                    }
                }
            }
        }
        stage('Wait') {
            steps {
                echo 'Waiting for server to start...'
                sleep time: 60, unit: 'SECONDS'
                echo 'Assuming that the server is started.'
            }
        }
    }
}
