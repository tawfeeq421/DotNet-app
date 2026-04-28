pipeline {
    agent any 
    tools{
        jdk 'JDK17'
    }
    environment{
        SONAR_HOME= tool 'sonar'
        DOCKER_IMAGE = "tawfeeq421/dotnet"
        DOCKER_TAG = "${BUILD_NUMBER}"
    }
    stages{
        stage('Clean Workspace'){
            steps{
                cleanWs()
            }
        }
        stage('Checkout SCM'){
            steps{
                git branch: 'main', url: 'https://github.com/tawfeeq421/DotNet-app.git'
            }
        }
        stage('Build'){
            steps{
                sh 'dotnet restore src/dotnet-demoapp.csproj'
                sh 'dotnet build src/dotnet-demoapp.csproj'
            }
        }
        stage('Unit Test'){
            steps{
                sh '''
                dotnet test tests/tests.csproj \
                --logger "trx;LogFileName=test-results.trx"
                '''
            }
        }
        stage('SonarQube Scan'){
            steps{
                withSonarQubeEnv('sonarserver'){
                sh"""
                ${SONAR_HOME}/bin/sonar-scanner \
                -Dsonar.projectName=dotnet \
                -Dsonar.projectKey=dotnet
                """
                }
            }
        }
        stage('Quality Gate'){
            steps{
                timeout(time: 1, unit: 'HOURS'){
                    waitForQualityGate abortPipeline: true
                }
            }
        }
        stage('Trivy FS Scan'){
            steps{
                sh '''
                trivy fs . \
                --severity HIGH,CRITICAL \
                --format table \
                --no-progress \
                -o trivy-report.txt
                '''
            }
        }
        stage('Docker Build'){
            steps{
                script{
                    def app = docker.build("${DOCKER_IMAGE}:${DOCKER_TAG}", ".")
                }
            }
        }
        stage('Scan Image and Push'){
            steps{
                script{
                    sh """
                    trivy image \
                    --severity HIGH,CRITICAL \
                    --format table \
                    --no-progress \
                    -o trivy-image-report \
                    ${DOCKER_IMAGE}:${DOCKER_TAG}
                    """
                    docker.withRegistry('https://index.docker.io/v1', 'docker-cred'){
                        app.push()
                        app.push('latest')
                }
                }
            }
        }
    }
    post{
        always{
            archiveArtifacts artifacts: 'trivy-report.txt', fingerprint: true
        }
        success{
            slackSend(
                channel: "#amazon",
                color: "good",
                message: "✅ SUCCESS: ${env.JOB_NAME} #${env.BUILD_NUMBER}\nCheck ${env.BUILD_URL}"
            )
        }
        failure{
            slackSend(
                channel: "#amazon",
                color: "danger",
                message: "❌ FAILURE: ${env.JOB_NAME} #${env.BUILD_NUMBER}\n See Logs ${env.BUILD_URL}"
            )
        }
    }
}