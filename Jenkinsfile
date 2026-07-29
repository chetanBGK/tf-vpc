pipeline{
    agent any

    stages{
        stage("checkout"){
            steps{
                git branch: 'main', url: 'https://github.com/chetanBGK/tf-vpc.git'
            }
        }

       
  stages {
        stage('Terraform Init') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-creds'
                ]]) {
                    sh 'terraform init'
                    sh 'terraform plan'
                }
            }
        }
    }

  stage('plan') {
    steps {
        sh 'terraform plan'
    }
  }

  stage('apply') {
    steps {
        sh 'terraform apply -auto-approve'
    }
  }




    }
}
