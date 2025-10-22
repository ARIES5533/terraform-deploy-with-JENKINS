// pipeline {
//   agent any

//   environment {
//     AWS_CREDENTIALS_ID = 'aws-cred'  // Jenkins credential ID
//     TF_BACKEND_BUCKET  = 'terraform-state-jenkins5533'
//     TF_BACKEND_REGION  = 'us-east-1'
//   }

//   stages {
//     stage('Checkout') {
//       steps {
//         checkout scm
//       }
//     }

//     stage('Setup AWS Credentials') {
//       steps {
//         withAWS(credentials: "${AWS_CREDENTIALS_ID}", region: "${TF_BACKEND_REGION}") {
//           echo "AWS credentials configured."
//         }
//       }
//     }

//     stage('Terraform Init') {
//         steps {
//             sh '''
//             terraform init -reconfigure \
//             -backend-config="bucket=terraform-state-jenkins5533" \
//             -backend-config="region=us-east-1"
//             '''
//         }
//     }


//     stage('Terraform Validate') {
//       steps {
//         sh 'terraform validate'
//       }
//     }

//     stage('Terraform Plan') {
//       steps {
//         sh 'terraform plan -out=tfplan'
//       }
//     }

//     stage('Terraform Apply') {
//       steps {
//         input message: 'Approve to apply Terraform changes?'
//         sh 'terraform apply -auto-approve tfplan'
//       }
//     }
//   }
// }

pipeline {
  agent any

  environment {
    AWS_CREDENTIALS_ID = 'aws-cred'
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
          echo "✅ AWS credentials configured."
        }
      }
    }
    stage('Snyk Security Scan') {
      steps {
        withCredentials([string(credentialsId: 'snyk', variable: 'SNYK_TOKEN')]) {
        sh '''
          echo "🔍 Running Snyk IaC scan on Terraform directory..."
          cd jenkins-terraform
          snyk iac test jenkins-terraform --token=$SNYK_TOKEN || true

          # Optional: uncomment this if you have Docker image scanning later
          # echo "🐳 Running Snyk Container scan..."
          # snyk container test <image_name> --token=$SNYK_TOKEN || true

          echo "✅ Snyk scan completed."
        '''
        }
      }
    }

    stage('Terraform Init') {
    steps {
        timeout(time: 5, unit: 'MINUTES') {
        sh '''
            set -e
            rm -rf .terraform .terraform.lock.hcl
            terraform init -input=false -no-color -reconfigure \
            -backend-config="bucket=terraform-state-jenkins5533" \
            -backend-config="region=us-east-1"
        '''
        }
    }
    }


    stage('Terraform Validate') {
      steps {
        timeout(time: 5, unit: 'MINUTES') {
          sh '''
            set -e
            terraform validate
            echo "✅ Terraform validation successful."
          '''
        }
      }
    }

    stage('Terraform Plan') {
      steps {
        timeout(time: 10, unit: 'MINUTES') {
          sh '''
            set -e
            terraform plan -out=tfplan
            echo "✅ Terraform plan completed."
          '''
        }
      }
    }

    stage('Terraform Apply') {
      steps {
        input message: 'Approve to apply Terraform changes?'
        timeout(time: 10, unit: 'MINUTES') {
          sh '''
            set -e
            terraform apply -auto-approve tfplan
            echo "✅ Terraform apply completed successfully."
          '''
        }
      }
    }
  }
}
