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
    }
}