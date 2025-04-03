pipeline {
    agent { label 'built-in' }
    
    options {
        disableConcurrentBuilds()
    }

    environment {
        START_SERVER_IF_NOT_RUNNING = 'false'
        INSTANCE_NAME = 'minecraft-fabric-modpack'
        SERVER_DIR = ''
        SERVER_PORT = '25565'
    }

    stages {
        stage ('Stop Minecraft Server') {
            steps {
                script {
                    def portOpen = sh(script: "netstat -tuln | grep ':${env.SERVER_PORT}' || echo 'not running'", returnStdout: true).trim()

                    if (portOpen == 'not running') {
                        if (env.START_SERVER_IF_NOT_RUNNING != 'true') {
                            echo 'Minecraft server is not running. Marking pipeline as successful.'
                            currentBuild.result = 'SUCCESS'
                            return
                        }
                    } else {
                        echo 'Minecraft server is running. Stopping...'
                        sh "screen -S ${env.INSTANCE_NAME} -X stuff \"stop^M\""
                    }

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
        stage('Start Minecraft Server') {
            steps {
                script {
                    withCredentials([string(credentialsId: 'MINECRAFT_FABRIC_SERVER_DIR', variable: 'SERVER_DIR')]) {
                        if (!env.SERVER_DIR?.trim()) {
                            error 'SERVER_DIR is empty. Pipeline will be aborted.'
                        }

                        if (!fileExists(env.SERVER_DIR)) {
                            error 'SERVER_DIR does not contain files. Pipeline will be aborted.'
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
                sleep time: 300, unit: 'SECONDS'
                echo 'Assuming that the server is started.'
            }
        }
    }
}
