pipeline {
    agent { label 'built-in' }
    
    options {
        disableConcurrentBuilds()
    }

    environment {
        INSTANCE_NAME = 'minecraft-fabric-modpack'
        SERVER_DIR = ''
        SERVER_PORT = '25565'
    }

    stages {
        stage ('Stop Minecraft Server') {
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

                        def portOpen = sh(script: "netstat -tuln | grep ':${env.SERVER_PORT}' || echo 'not running'", returnStdout: true).trim()
                        if (portOpen == 'not running') {
                            echo 'Minecraft server is not running.'
                        } else {
                            echo 'Minecraft server is running. Stopping...'
                            sh "sudo -u minecraft ${env.SERVER_DIR}/stop-detached.sh"
                            sleep time: 15, unit: 'SECONDS'

                            portOpen = sh(script: "netstat -tuln | grep ':${env.SERVER_PORT}' || echo 'not running'", returnStdout: true).trim()
                            if (portOpen == 'not running') {
                                echo 'Minecraft server is not running.'
                            } else {
                                echo 'Minecraft server is running after 15 seconds. Trying to stop again...'
                                sh "sudo -u minecraft ${env.SERVER_DIR}/stop-detached.sh"
                                sleep time: 20, unit: 'SECONDS'
                                portOpen = sh(script: "netstat -tuln | grep ':${env.SERVER_PORT}' || echo 'not running'", returnStdout: true).trim()
                                if (portOpen == 'not running') {
                                    echo 'Minecraft server is not running.'
                                } else {
                                    error 'Could not stop minecraft server. Manual intervention required!'
                                }
                            }
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
                            sh "sudo -u minecraft git -C ${env.SERVER_DIR} pull"
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
                            echo 'Starting minecraft server...'
                            sh "sudo -u minecraft ${env.SERVER_DIR}/run-detached.sh"
                            echo 'Waiting for server to start...'
                            sleep time: 300, unit: 'SECONDS'
                            def portOpen = sh(script: "netstat -tuln | grep ':${env.SERVER_PORT}' || echo 'not running'", returnStdout: true).trim()
                            if (portOpen == 'not running') {
                                error 'Minecraft server did NOT start.'
                            } else {
                                echo 'Minecraft server is running.'
                            }
                        }
                    }
                }
            }
        }
    }
}
