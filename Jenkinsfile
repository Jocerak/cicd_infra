pipeline {
  agent any

  environment {
    TF_VAR_file = "infra.tfplan"
  }

  stages {

    stage('🧾 Checkout') {
      steps {
        checkout scm
      }
    }

    stage('🧪 Test - Validation Terraform') {
      steps {
        echo '🔍 Validation de la syntaxe...'
        sh 'terraform init -backend=false'
        sh 'terraform validate'
        echo '✅ Fichiers Terraform valides'
      }
    }

    stage('⚙️ Build - Génération du plan') {
      steps {
        withCredentials([
          string(credentialsId: 'AWS_ACCESS_KEY_ID', variable: 'AWS_ACCESS_KEY_ID'),
          string(credentialsId: 'AWS_SECRET_ACCESS_KEY', variable: 'AWS_SECRET_ACCESS_KEY')
        ]) {
          sh '''
            export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
            export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY

            terraform init
            terraform plan -out=$TF_VAR_file
          '''
        }
      }
    }

    
    stage('🚀 Deploy - Application du plan') {
      steps {
        withCredentials([
          string(credentialsId: 'AWS_ACCESS_KEY_ID', variable: 'AWS_ACCESS_KEY_ID'),
          string(credentialsId: 'AWS_SECRET_ACCESS_KEY', variable: 'AWS_SECRET_ACCESS_KEY')
        ]) {
          sh '''
            export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
            export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY

            terraform destroy -auto-approve $TF_VAR_file
          '''
        }
      }
    }

    stage('🧹 Optional Destroy') {
      when {
        expression { return false } // change to true if you want auto destroy stage
      }
      steps {
        withCredentials([
          string(credentialsId: 'AWS_ACCESS_KEY_ID', variable: 'AWS_ACCESS_KEY_ID'),
          string(credentialsId: 'AWS_SECRET_ACCESS_KEY', variable: 'AWS_SECRET_ACCESS_KEY')
        ]) {
          sh '''
            export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
            export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY

            terraform destroy -auto-approve
          '''
        }
      }
    }
  }

  post {
    failure {
      echo "❌ Échec du pipeline."
    }
    success {
      echo "✅ Pipeline terminé avec succès."
    }
  }
}
