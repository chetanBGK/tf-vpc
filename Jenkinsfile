pipeline{
    agent any

    stages{
        stage("checkout"){
            steps{
                git branch: 'main', url: 'https://github.com/chetanBGK/tf-vpc.git'
            }
        }

       stages {
  stage('init') {
    steps {
      sh 'terraform init'
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
}
