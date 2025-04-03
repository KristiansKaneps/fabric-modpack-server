pipeline {
    agent { label 'master' }
    
    options {
        disableConcurrentBuilds()
    }

    environment {
        SERVER_DIR = ''
    }

    stages {
        stage('Setup Minecraft Server') {
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
        stage('Wait') {
            echo 'Waiting for server to start...'
            sleep time: 60, unit: 'SECONDS'
            echo 'Assuming that the server is started.'
        }
    }
}
