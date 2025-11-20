pipeline {
    agent any
    tools {
        maven 'choco_maven'
        git 'Default'
        jdk 'jdk_21'
    }

    environment {
        PATH = "C:\\Program Files\\Docker\\Docker\\resources\\bin;${env.PATH}"
        JAVA_HOME = 'C:\\Program Files\\Java\\jdk-21'
        SONARQUBE_SERVER = 'SonarQube'
        SONAR_TOKEN = 'sqa_77e63b3976efcdb1d5c825057b5f26bad6cad8a4'
        DOCKERHUB_CREDENTIALS_ID = 'Docker_Hub'
        DOCKERHUB_REPO = 'ekuuu/sep2_week5_f2025_inclass'
        DOCKER_IMAGE_TAG = 'latest'
        DOCKER_IMAGE = "${DOCKERHUB_REPO}:${DOCKER_IMAGE_TAG}"
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
                bat "docker build -t ${env.DOCKER_IMAGE} ."
            }
        }

        stage('Push Docker Image to Docker Hub') {
            steps {
                withCredentials([usernamePassword(credentialsId: DOCKERHUB_CREDENTIALS_ID, usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    bat "echo %DOCKER_PASS% | docker login -u %DOCKER_USER% --password-stdin"
                    bat "docker push ${env.DOCKER_IMAGE}"
                }
            }
        }
    }

    post {
        always {
            junit '**/target/surefire-reports/*.xml'
            jacoco execPattern: '**/target/jacoco.exec', classPattern: '**/target/classes', sourcePattern: '**/src/main/java'
            bat 'docker logout'
        }
        success {
            echo 'Build and tests succeeded!'
        }
        failure {
            echo 'Build or tests failed.'
        }
    }
}