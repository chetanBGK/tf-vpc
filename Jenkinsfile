pipeline {
    agent any

    stages {

        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/chetanBGK/tf-vpc.git'
            }
        }

        stage('Terraform Init') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-creds'
                ]]) {
                   sh '''
                        terraform init
                        terraform destroy -auto-approve
                    '''
                }
            }
        }

        

       
        
    }
}
