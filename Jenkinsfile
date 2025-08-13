pipeline {
  agent {
    dockerfile {
      filename 'Dockerfile'
      dir 'jenkins-agent'
      additionalBuildArgs '--pull'
      args '''
        --network jenkins
        -v dind_certs:/dind-certs:ro
        -e DOCKER_HOST=tcp://docker:2376
        -e DOCKER_TLS_VERIFY=1
        -e DOCKER_CERT_PATH=/dind-certs/client
      '''
    }
  }

  environment {
    IMAGE_NAME     = 'spring-petclinic-app'
    IMAGE_TAG      = "build-${BUILD_NUMBER}"
    CONTAINER_NAME = 'spring-petclinic'
    DOCKER_HOST       = 'tcp://docker:2376'
    DOCKER_TLS_VERIFY = '1'
    DOCKER_CERT_PATH  = '/dind-certs/client'
  }

  stages {
    stage('Sanity check') {
      steps {
        sh '''
          echo "DOCKER_HOST=$DOCKER_HOST"
          ls -l /dind-certs/client
          test -f /dind-certs/client/ca.pem
          docker version
        '''
      }
    }

    stage('Clone Petclinic') {
      steps {
        git branch: 'main', url: 'https://github.com/yashwanthk147/spring-petclinic.git'
      }
    }

    stage('Start Docker Compose') {
      steps {
        echo 'Stopping and starting containers via Docker Compose...'
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
          }
        }
      }
    }

    stage('Static Code Analysis') {
      steps {
        sh 'mvn --batch-mode -V -U -e verify -Dspring.profiles.active=postgres'
        recordIssues enabledForFailure: true, tools: [
          [$class: 'CheckStyle', pattern: '**/target/checkstyle-result.xml'],
          [$class: 'Pmd',        pattern: '**/target/pmd.xml'],
          [$class: 'Cpd',        pattern: '**/target/cpd.xml'],
          [$class: 'SpotBugs',   pattern: '**/target/spotbugsXml.xml']
        ]
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
