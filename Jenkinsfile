pipeline {
  agent any

  environment {
    AWS_CREDENTIALS_ID = 'aws-creds'  // Jenkins credential ID
    TF_BACKEND_BUCKET  = 'terraform-state-jenkins5533'
    TF_BACKEND_REGION  = 'us-east-1'
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Setup AWS Credentials') {
      steps {
        withAWS(credentials: "${AWS_CREDENTIALS_ID}", region: "${TF_BACKEND_REGION}") {
          echo "AWS credentials configured."
        }
      }
    }

    stage('Terraform Init') {
      steps {
        sh '''
          terraform init \
            -backend-config="bucket=${TF_BACKEND_BUCKET}" \
            -backend-config="region=${TF_BACKEND_REGION}"
        '''
      }
    }

    stage('Terraform Validate') {
      steps {
        sh 'terraform validate'
      }
    }

    stage('Terraform Plan') {
      steps {
        sh 'terraform plan -out=tfplan'
      }
    }

    stage('Terraform Apply') {
      steps {
        input message: 'Approve to apply Terraform changes?'
        sh 'terraform apply -auto-approve tfplan'
      }
    }
  }
}
