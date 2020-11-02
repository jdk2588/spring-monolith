#!/usr/bin/env groovy

pipeline {
 environment {
  appName = "monolith"
  registry = "jdk2588/monolith"
  registryCredential = "docker"
  projectPath = "/jenkins/data/workspace/ftgo-monolith"
  commit = "${GIT_COMMIT.substring(0,8)}"
 }

 agent any

 parameters {
 stages {
  stage('Basic Information') {
   steps {
    sh "echo ${params.RELEASE_TAG} ${commit}"
   }
  }

/*
  stage('Check Lint') {
   steps {
    sh "docker run --rm $registry:${commit} flake7 --ignore=E501,F401,W391"
   }
  }
*/

  stage('Build and test') {
   steps {
    script {
      sh "./build-and-test-all.sh"
      dockerImage = docker.build "ftgo-application $registry:${commit}"
    }
   }
  }

  stage('Run Tests') {
   steps {
    sh "docker run -v $projectPath/reports:/app/reports  --rm --network='host' $registry:${commit} python martor_demo/manage.py test"
   }
  }

  stage('Push Image') {
   steps {
    script {
     if (isMaster()) {
      docker.withRegistry("", registryCredential) {
      dockerImage.push()
      }
     }
    }
   }
  }

  stage('Notify Telegram') {
   steps() {
    script {
     if (isMaster()) {
      telegram.sendTelegram("Build successful for ${getBuildName()}\n" +
      "image $registry:${params.RELEASE_TAG} is pushed to DockerHub and ready to be deployed")
     }
    }
   }
  }

  stage('Garbage Collection') {
   steps {
    script {
    	if (isMaster()) {
      	 sh "docker rmi $registry:${commit}"
    	}
    }
   }
  }

  /*
  stage ('Deploy') {
      steps {
       script {
    	if (isMaster()) {
         build job: 'django-markdown-deploy', wait: false, parameters: [stringParam(name: 'target', value: "${commit}")]
        }
      }
    }
  }
   */

 }

 post {
  failure {
   script {
    telegram.sendTelegram("Build failed for ${getBuildName()}\n" +
     "Checkout Jenkins console for more information. If you are not a developer simply ignore this message.")
   }
  }
 }

}

def getBuildName() {
 "${BUILD_NUMBER}_$appName:${commit}"
}

def isMaster() {
 get_branch_name() == "master"
}

def get_branch_name() {
  if (env.GIT_BRANCH.contains("master")) {
    return "master"
  } else {
    try {
      return env.GIT_BRANCH.split('/')[-1]
    } catch(Exception e) {
      error "Could not find branch name."
    }
  }
}