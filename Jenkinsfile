pipeline {
    agent {
        dockerfile {
          filename 'Dockerfile'
          dir 'jenkins-agent'          
          additionalBuildArgs '--pull'
          args '''
            --network jenkins
            -v dind_certs:/dind-certs:ro
          '''
        }
    }

    environment {
        IMAGE_NAME = 'spring-petclinic-app'
        IMAGE_TAG = "build-${BUILD_NUMBER}"
        CONTAINER_NAME = "spring-petclinic"
        DOCKER_HOST       = 'tcp://docker:2376'
        DOCKER_TLS_VERIFY = '1'
        DOCKER_CERT_PATH  = '/dind-certs/client'
    }

    stages {

        stage('Clone Petclinic') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/yashwanthk147/spring-petclinic.git'
            }
        }

        stage('Start Docker Compose') {
            steps {
                echo 'Stopping and starting containers via Docker Compose...'
                //sh 'docker compose down || true'
                sh 'aws --version'
                sh 'docker compose up -d'
                sh 'docker ps -a'
            }
        }

        stage('Build & Run Unit Tests') {
            steps {
                sh 'mvn clean verify -Dspring.profiles.active=postgres'
            }
            post {
                always {
                    echo 'Archiving test reports'
                    catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                        junit '**/target/surefire-reports/*.xml'
                        // Uncomment if using Failsafe plugin
                        // junit '**/target/failsafe-reports/*.xml'
                    }
                }
            }
        }

        stage('Static Code Analysis') {
            steps {
                echo 'Running Maven static analysis plugins...'
                sh 'mvn --batch-mode -V -U -e verify -Dspring.profiles.active=postgres'

                echo 'Recording Checkstyle, PMD, CPD, SpotBugs reports...'
                recordIssues enabledForFailure: true, tools: [
                    [$class: 'CheckStyle', pattern: '**/target/checkstyle-result.xml'],
                    [$class: 'Pmd', pattern: '**/target/pmd.xml'],
                    [$class: 'Cpd', pattern: '**/target/cpd.xml'],
                    [$class: 'SpotBugs', pattern: '**/target/spotbugsXml.xml']
                ]

                echo 'Archiving static analysis reports...'
                archiveArtifacts artifacts: '**/target/*.xml', onlyIfSuccessful: true
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .'
            }
        }

        stage('Run Docker Container') {
            steps {
                sh '''
                    docker rm -f ${CONTAINER_NAME} || echo "No existing container to remove"
                    docker run -d -p 9090:9090 --name ${CONTAINER_NAME} ${IMAGE_NAME}:${IMAGE_TAG}
                '''
            }
        }

        stage('Save Docker Image') {
            steps {
                sh 'docker save -o ${IMAGE_NAME}-${IMAGE_TAG}.tar ${IMAGE_NAME}:${IMAGE_TAG}'
                archiveArtifacts artifacts: "${IMAGE_NAME}-${IMAGE_TAG}.tar", fingerprint: true
            }
        }
    }
}
