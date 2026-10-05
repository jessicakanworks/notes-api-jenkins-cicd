pipeline {
  agent any
  options { timestamps(); disableConcurrentBuilds(); buildDiscarder(logRotator(numToKeepStr: '20')) }
  environment {
    REGISTRY = 'docker.io/CHANGEME'
    IMAGE    = "${REGISTRY}/notes-app"
    TAG      = "${env.BRANCH_NAME}-${env.BUILD_NUMBER}"
    SHA      = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
    DEPLOY_HOST = 'ubuntu@YOUR_EC2_PUBLIC_IP'
  }
  stages {
    stage('Test') {
      agent { docker { image 'python:3.12-slim'; reuseNode true } }
      steps {
        sh 'pip install -q -r app/requirements.txt pytest && pytest -q tests/'
      }
    }
    stage('Build') {
      steps { sh "docker build -t ${IMAGE}:${TAG} -t ${IMAGE}:${SHA} ." }
    }
    stage('Push') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'registry-creds', usernameVariable: 'U', passwordVariable: 'P')]) {
          sh 'echo "$P" | docker login -u "$U" --password-stdin ${REGISTRY}'
          sh "docker push ${IMAGE}:${TAG} && docker push ${IMAGE}:${SHA}"
        }
      }
    }
    stage('Deploy') {
      when { branch 'main' }
      steps {
        sshagent(['deploy-ssh-key']) {
          sh "scp -o StrictHostKeyChecking=no scripts/deploy.sh docker-compose.yml ${DEPLOY_HOST}:~/"
          sh "ssh -o StrictHostKeyChecking=no ${DEPLOY_HOST} 'REGISTRY=${REGISTRY} TAG=${SHA} bash ~/deploy.sh'"
        }
      }
    }
  }
  post {
    success { echo "Deployed ${IMAGE}:${SHA}" }
    failure { echo 'Build failed — check stage logs' }
    always  { sh 'docker image prune -f || true' }
  }
}
