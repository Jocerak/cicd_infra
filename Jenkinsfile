pipeline {
  agent any

  stages {
    stage('📦 Init Terraform') {
      steps {
        withCredentials([
          string(credentialsId: 'AWS_ACCESS_KEY_ID', variable: 'AWS_ACCESS_KEY_ID'),
          string(credentialsId: 'AWS_SECRET_ACCESS_KEY', variable: 'AWS_SECRET_ACCESS_KEY')
        ]) {
          sh '''
            terraform init
          '''
        }
      }
    }

    stage('⚙️ Plan + Apply') {
      steps {
        withCredentials([
          string(credentialsId: 'AWS_ACCESS_KEY_ID', variable: 'AWS_ACCESS_KEY_ID'),
          string(credentialsId: 'AWS_SECRET_ACCESS_KEY', variable: 'AWS_SECRET_ACCESS_KEY')
        ]) {
          sh '''
            terraform plan -out=tfplan
            terraform apply -auto-approve tfplan
          '''
        }
      }
    }
  }

  post {
    success {
      echo "✅ Archive du fichier terraform.tfstate"
      archiveArtifacts artifacts: 'terraform.tfstate', fingerprint: true
    }
    always {
      echo "🏁 Fin du pipeline apply"
    }
  }
}
