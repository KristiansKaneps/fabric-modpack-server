// RCON will be automatically enabled. Make sure that the RCON is not accessible from the outside.

def skipPipeline = false
def serverStarted = false

pipeline {
    agent { label 'built-in' }
    
    options {
        disableConcurrentBuilds()
        buildDiscarder(logRotator(numToKeepStr: '10', artifactNumToKeepStr: '3'))
        skipStagesAfterUnstable()
    }

    environment {
        GIT_REPOSITORY_URL = 'git@github.com:KristiansKaneps/fabric-modpack-server.git'
        GIT_REPOSITORY_BRANCH = 'master'

        SERVER_DIR = ''
        SERVER_HOST = '127.0.0.1'
        SERVER_PORT = '25565'
        SERVER_RCON_PORT = '25575'
        SERVER_RCON_PASS = 'secret'
    }

    stages {
        stage('Check latest commit message') {
            steps {
                script {
                    withCredentials([string(credentialsId: 'MINECRAFT_FABRIC_SERVER_DIR', variable: 'SERVER_DIR')]) {
                        def commitMessage = sh(script: "git log -1 --pretty=%B ${env.GIT_COMMIT}", returnStdout: true).trim()
                        echo "Commit message: ${commitMessage}"
                        if (commitMessage.startsWith("PUBLISH")) {
                            skipPipeline = true
                            echo "Skipping pipeline execution due to 'PUBLISH' commit message"
                        }
                    }
                }
            }
        }
        stage('Stop Minecraft Server') {
            when {
                expression {
                    return !skipPipeline
                }
            }
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

                        def portOpen = isPortOpen(env.SERVER_PORT)
                        if (!portOpen) {
                            echo 'Minecraft server is not running.'
                        } else {
                            echo 'Minecraft server is running. Stopping...'

                            def timeout = 180
                            def sleepInterval = 5
                            def elapsedTime = 0

                            def rconPortOpen = isPortOpen(env.SERVER_RCON_PORT)
                            if (!rconPortOpen) {
                                echo 'Minecraft RCON port is not yet open. Waiting...'
                                while (elapsedTime < timeout) {
                                    rconPortOpen = isPortOpen(env.SERVER_RCON_PORT)
                                    if (rconPortOpen) {
                                        sleep time: 15, unit: 'SECONDS'
                                        break
                                    }
                                    sleep time: sleepInterval, unit: 'SECONDS'
                                    elapsedTime += sleepInterval
                                }
                                if (!rconPortOpen) {
                                    echo 'Minecraft RCON port is still not open. Trying to stop manually...'
                                    sh "sudo -u minecraft ${env.SERVER_DIR}/stop-detached.sh"
                                } else {
                                    echo 'Minecraft RCON port is open. Trying to stop through RCON...'
                                    if (!stopServer(env.SERVER_HOST, env.SERVER_RCON_PORT, env.SERVER_RCON_PASS)) {
                                        echo 'Minecraft RCON authentication failure. Trying to stop again manually...'
                                        sh "sudo -u minecraft ${env.SERVER_DIR}/stop-detached.sh"
                                    }
                                }
                                sleep time: 15, unit: 'SECONDS'
                            } else {
                                echo 'Minecraft RCON port is open. Trying to stop through RCON...'
                                def playerCount = checkPlayerCount(env.SERVER_HOST, env.SERVER_RCON_PORT, env.SERVER_RCON_PASS)
                                if (playerCount == -1) {
                                    echo "Could not check online player count due to an error. Assuming there are no players online."
                                } else {
                                    echo "Currently online player count: $playerCount"
                                }
                                if (playerCount > 0) {
                                    echo 'There are players currently in the server. Broadcasting countdown...'

                                    def countdownSeconds = 60
                                    def interval = 10

                                    while (countdownSeconds > 0) {
                                        if (countdownSeconds == 1) {
                                            echo "Server is stopping in ${countdownSeconds} second..."
                                            broadcastMessage(env.SERVER_HOST, env.SERVER_RCON_PORT, env.SERVER_RCON_PASS, "Server will stop/restart in ${countdownSeconds} second!")
                                        } else {
                                            echo "Server is stopping in ${countdownSeconds} seconds..."
                                            broadcastMessage(env.SERVER_HOST, env.SERVER_RCON_PORT, env.SERVER_RCON_PASS, "Server will stop/restart in ${countdownSeconds} seconds!")
                                        }
                                        if (countdownSeconds <= 10) {
                                            interval = 1
                                        } else if (countdownSeconds <= 30) {
                                            interval = 5
                                        }
                                        sleep time: interval, unit: 'SECONDS'
                                        countdownSeconds -= interval
                                    }
                                    echo "Server is stopping now!"
                                    broadcastMessage(env.SERVER_HOST, env.SERVER_RCON_PORT, env.SERVER_RCON_PASS, 'Server is stopping/restarting now!')
                                }
                                if (!stopServer(env.SERVER_HOST, env.SERVER_RCON_PORT, env.SERVER_RCON_PASS)) {
                                    echo 'Minecraft RCON authentication failure. Trying to stop again manually...'
                                    sh "sudo -u minecraft ${env.SERVER_DIR}/stop-detached.sh"
                                }
                                sleep time: 15, unit: 'SECONDS'
                            }

                            portOpen = isPortOpen(env.SERVER_PORT) || isPortOpen(env.SERVER_RCON_PORT)
                            if (!portOpen) {
                                echo 'Minecraft server is not running. Continuing...'
                            } else {
                                echo 'Waiting for server to stop...'

                                timeout = 300
                                sleepInterval = 5
                                elapsedTime = 0

                                while (elapsedTime < timeout) {
                                    portOpen = isPortOpen(env.SERVER_PORT) || isPortOpen(env.SERVER_RCON_PORT)
                                    if (!portOpen) {
                                        break
                                    }
                                    sleep time: sleepInterval, unit: 'SECONDS'
                                    elapsedTime += sleepInterval
                                }

                                if (elapsedTime >= timeout) {
                                    error 'Minecraft server did not stop within timeout. Trying to stop again...'
                                    sleep time: 5, unit: 'SECONDS'

                                    sh "sudo -u minecraft ${env.SERVER_DIR}/stop-detached.sh"
                                    sleep time: 20, unit: 'SECONDS'
                                    portOpen = isPortOpen(env.SERVER_PORT)
                                    if (!portOpen) {
                                        echo 'Minecraft server is not running. Continuing...'
                                    } else {
                                        error 'Could not stop minecraft server. Manual intervention required!'
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        stage('Setup Minecraft Server') {
            when {
                expression {
                    return !skipPipeline
                }
            }
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
                            sh "sudo -u minecraft git -C ${env.SERVER_DIR} pull origin master"
                            sh """
                            rm -f server.properties
                            cp overwrite.server.properties server.properties
                            sed -i "s/^enable-rcon=.*/enable-rcon=true/" server.properties
                            sed -i "s/^rcon\\.password=.*/rcon.password=${env.SERVER_RCON_PASS}/" server.properties
                            sed -i "s/^rcon\\.port=.*/rcon.port=${env.SERVER_RCON_PORT}/" server.properties
                            """
                            sh 'ls'
                        }
                    }
                }
            }
        }
        stage('Start Minecraft Server') {
            when {
                expression {
                    return !skipPipeline
                }
            }
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

                            def timeout = 420
                            def sleepInterval = 5
                            def elapsedTime = 0

                            while (elapsedTime < timeout) {
                                def portOpen = isPortOpen(env.SERVER_PORT) && isPortOpen(env.SERVER_RCON_PORT)
                                if (portOpen) {
                                    echo 'Minecraft server is running.'
                                    serverStarted = true
                                    break
                                }
                                sleep time: sleepInterval, unit: 'SECONDS'
                                elapsedTime += sleepInterval
                            }

                            if (elapsedTime >= timeout) {
                                error 'Minecraft server did NOT start within timeout.'
                                sleep time: 5, unit: 'SECONDS'
                            }
                        }
                    }
                }
            }
        }
        stage('Publish new config files to repository') {
            when {
                expression {
                    return !skipPipeline && serverStarted
                }
            }
            steps {
                script {
                    withCredentials([string(credentialsId: 'MINECRAFT_FABRIC_SERVER_DIR', variable: 'SERVER_DIR')]) {
                        if (!env.SERVER_DIR?.trim()) {
                            error 'SERVER_DIR is empty. Pipeline will be aborted.'
                        }

                        if (!fileExists(env.SERVER_DIR)) {
                            error 'SERVER_DIR does not contain files. Pipeline will be aborted.'
                        }

                        def commitMessage = 'PUBLISH CONFIG - Changed files:'

                        dir(env.SERVER_DIR) {
                            def changeExist = sh(script: 'git status --porcelain', returnStdout: true).trim()
                            if (changeExist) {
                                def changedFiles = sh(script: "git diff --name-only", returnStdout: true).trim()
                                commitMessage += "\n" + changedFiles
                                sh 'sudo -u minecraft git add .'
                                sh "sudo -u minecraft git commit -m \"${commitMessage}\""
                                sh 'sudo -u minecraft git push origin master'
                            } else {
                                echo 'No changes detected, skipping commit and push.'
                            }
                        }
                    }
                }
            }
        }
    }
}

def broadcastMessage(String rconHost, String rconPort, String rconPassword, String message) {
    return sh(script: "./rcon/mcrcon -H '$rconHost' -P '$rconPort' -p '$rconPassword' 'say $message' || echo 'failed'", returnStdout: true).trim() != 'failed'
}

def checkPlayerCount(String rconHost, String rconPort, String rconPassword) {
    def text = sh(script: "./rcon/mcrcon -H '$rconHost' -P '$rconPort' -p '$rconPassword' 'list' || echo '0'", returnStdout: true).trim()
    if (text == '0') {
        return -1
    }

    // Clean up any non-printable characters (e.g., color codes)
    text = text.replaceAll(/\x1b\[[0-9;]*m/, '')

    // Example output from `list` command: "There are 3 of a max of 16 players online: player1, player2, player3"
    def matcher = text =~ /There are (\d+) of a max of \d+ players online/

    if (matcher) {
        return matcher[0][1].toInteger()
    } else {
        echo "Could not parse player count from: ${text}"
        return 0
    }
}

def stopServer(String rconHost, String rconPort, String rconPassword) {
    return sh(script: "./rcon/mcrcon -H '$rconHost' -P '$rconPort' -p '$rconPassword' 'stop' || echo 'failed'", returnStdout: true).trim() != 'failed'
}

def isPortOpen(String port) {
    return sh(script: "netstat -tuln | grep ':$port' || echo 'closed'", returnStdout: true).trim() != 'closed'
}
