pipeline {
    agent { label 'built-in' }
    
    options {
        disableConcurrentBuilds()
    }

    environment {
        SERVER_DIR = ''
        SERVER_PORT = '25565'
    }

    stages {
        stage ('Stop Minecraft Server') {
            steps {
                script {
                    def portOpen = sh(script: "netstat -tuln | grep ':${env.SERVER_PORT}' || echo 'not running'", returnStdout: true).trim()

                    if (portOpen == 'not running') {
                        echo 'Minecraft server is not running. Marking pipeline as successful.'
                        currentBuild.result = 'SUCCESS'
                        return
                    }

                    echo 'Minecraft server is running. Stopping...'

                    withCredentials([string(credentialsId: 'MINECRAFT_FABRIC_SERVER_DIR', variable: 'SERVER_DIR')]) {
                        if (!env.SERVER_DIR?.trim()) {
                            error 'SERVER_DIR is empty. Pipeline will be aborted.'
                        }

                        if (!fileExists(env.SERVER_DIR)) {
                            sh "mkdir -p ${env.SERVER_DIR}"
                        }

                        dir(env.SERVER_DIR) {
                            sh 'ls'
                        }
                    }
                }
            }
        }
        stage('Setup Minecraft Server') {
            steps {
                script {
                    withCredentials([string(credentialsId: 'MINECRAFT_FABRIC_SERVER_DIR', variable: 'SERVER_DIR')]) {
                        if (!env.SERVER_DIR?.trim()) {
                            error 'SERVER_DIR is empty. Pipeline will be aborted.'
                        }
                        
                        if (!fileExists(env.SERVER_DIR)) {
                            sh "mkdir -p ${env.SERVER_DIR}"
                        }
                        
                        dir(env.SERVER_DIR) {
                            sh 'ls'
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
