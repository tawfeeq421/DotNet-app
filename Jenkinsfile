pipeline {
    agent {
        label 'my-agent'
    }
    tools{
        jdk 'JDK17'
    }
    environment{
        SONAR_HOME= tool 'sonar'
        DOCKER_IMAGE = "tawfeeq421/dotnetapp"
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
                    sh """
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
                sh "docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} ."
            }
        }
        stage('Trivy Image Scan'){
            steps{
                sh """
                trivy image \
                --severity HIGH,CRITICAL \
                --format table \
                --no-progress \
                -o trivy-image-report.txt \
                ${DOCKER_IMAGE}:${DOCKER_TAG}
                """
            }
        }
        stage('Docker Push'){
            steps{
                withCredentials([usernamePassword(
                    credentialsId: 'docker-cred',
                    usernameVariable: 'USER',
                    passwordVariable: 'PASS'
                )]){
                    sh '''
                    echo $PASS | docker login -u $USER --password-stdin

                    docker push ${DOCKER_IMAGE}:${DOCKER_TAG}

                    docker tag ${DOCKER_IMAGE}:${DOCKER_TAG} ${DOCKER_IMAGE}:latest
                    docker push ${DOCKER_IMAGE}:latest
                    '''
                }
            }
        }
    }
    post{
        always{
            archiveArtifacts artifacts: 'trivy-report.txt, trivy-image-report.txt', fingerprint: true
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
