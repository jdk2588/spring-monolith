#!/usr/bin/env groovy

library identifier: 'jenkins-shared@master', retriever: modernSCM(
 [$class: 'GitSCMSource',
  remote: 'https://github.com/MobodidTech/jenkins-shared.git',
])

pipeline {
 environment {
  appName = "monolith"
  registry = "jdk2588/monolith"
  registryCredential = "docker"
  commit = "${GIT_COMMIT.substring(0, 8)}"
 }

 agent any

 stages {
  stage('Basic Information') {
   steps {
    sh "echo ${params.RELEASE_TAG} ${commit}"
   }
  }

  stage('Linter Run') {
   steps {
    sh "echo lint"
   }
  }

  stage('Test') {
   steps {
    script {
     sh "/bin/bash test.sh"
     sh "cd $WORKSPACE/ftgo-application && docker build -t $registry:${commit} ."
    }
   }
  }

  stage('Build') {
   steps {
    script {
     sh "/bin/bash build.sh $registry ${commit}"
    }
   }
  }

  stage('Push Image') {
   steps {
    script {
     docker.withRegistry("", registryCredential) {
      docker.image("$registry:${commit}").push()
     }
    }
   }
  }

  stage('Notify Telegram') {
   steps() {
    script {
     if (ismain()) {
      telegram.sendTelegram("Build successful for ${getBuildName()}\n" +
              "image $registry:${params.RELEASE_TAG} is pushed to DockerHub and ready to be deployed")
     }
    }
   }
  }

  stage('Garbage Collection') {
   steps {
    script {
     if (ismain()) {
      sh "docker rmi $registry:${commit}"
     }
    }
   }
  }

  stage ('Deploy') {
       steps {
        script {
         if (ismain()) {
          build job: 'spring-monolith-deploy', wait: true, parameters: [stringParam(name: 'target', value: "${commit}")]
         }
       }
     }
   }

  stage ('Migrate') {
   steps {
    script {
     sh "DB_USER=mysqluser HOST_IP=192.168.56.4 DB_PASSWORD=mysqlpw ./gradlew flywayMigrate"
    }
   }
  }

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

def ismain() {
 get_branch_name() == "main"
}

def get_branch_name() {
 if (env.GIT_BRANCH.contains("main")) {
  return "main"
 } else {
  try {
   return env.GIT_BRANCH.split('/')[-1]
 } catch(Exception e) {
   error "Could not find branch name."
  }
 }
}
