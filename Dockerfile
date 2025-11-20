pipeline {
    agent any
    tools {
        maven 'ChocoMaven'
        git 'Default'
        jdk 'JDK'
    }

    environment {
     PATH = "C:\\Program Files\\Docker\\Docker\\resources\\bin;${env.PATH}"
        JAVA_HOME = 'C:\\Program Files\\Java\\jdk-21'  // Adjust to your actual JDK pat
        SONARQUBE_SERVER = 'SonarQube'  // The name of the SonarQube server configured in Jenkins
        SONAR_TOKEN = 'sqa_77e63b3976efcdb1d5c825057b5f26bad6cad8a4' // Store the token securely
        DOCKERHUB_CREDENTIALS_ID = 'Docker_Hub'
        DOCKERHUB_REPO = 'amirdirin/sep2_week5_f2025_inclass'
        DOCKER_IMAGE_TAG = 'latest'


    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'master', url: 'https://github.com/ADirin/sep2_week5_inclass_s2.git'
            }
        }

        stage('Build') {
            steps {
                bat 'mvn clean install'
            }
        }

        stage('SonarQube Analysis') {
                    steps {
                        withSonarQubeEnv('SonarQube') {
                            bat """
                                ${tool 'SonarScanner'}\\bin\\sonar-scanner ^
                                -Dsonar.projectKey=devops-demo ^
                                -Dsonar.sources=src ^
                                -Dsonar.projectName=DevOps-Demo ^
                                -Dsonar.host.url=http://localhost:9000 ^
                                -Dsonar.login=${env.SONAR_TOKEN} ^
                                -Dsonar.java.binaries=target/classes
                            """
                        }
                    }
                }



        stage('Build Docker Image') {
                    steps {
                        script {
                            docker.build("${DOCKERHUB_REPO}:${DOCKER_IMAGE_TAG}")
                            // Or specify Dockerfile path explicitly if needed
                            // docker.build("${DOCKERHUB_REPO}:${DOCKER_IMAGE_TAG}", "-f ./Dockerfile .")
                        }
                    }
                }

                stage('Push Docker Image to Docker Hub') {
                    steps {
                        script {
                            docker.withRegistry('https://index.docker.io/v1/', DOCKERHUB_CREDENTIALS_ID) {
                                docker.image("${DOCKERHUB_REPO}:${DOCKER_IMAGE_TAG}").push()
                            }
                        }
                    }
                }
    }
}