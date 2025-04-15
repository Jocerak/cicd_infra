pipeline {
    agent any

    environment {
        TF_DIR = '.'                     // Dossier contenant main.tf, etc.
        TF_PLAN = 'infra.tfplan'         // Nom du plan
    }

    parameters {
        booleanParam(name: 'DESTROY_INFRA', defaultValue: false, description: 'Détruire l’infrastructure après le déploiement ?')
    }

    stages {

        stage('🧪 Test - Validation Terraform') {
            steps {
                dir(env.TF_DIR) {
                    echo "🔍 Validation de la syntaxe..."
                    sh 'terraform init -backend=false'
                    sh 'terraform validate'
                    echo "✅ Fichiers Terraform valides"
                }
            }
        }

        stage('⚙️ Build - Génération du plan') {
            steps {
                dir(env.TF_DIR) {
                    sh 'terraform init'
                    sh "terraform plan -out=${TF_PLAN}"
                    echo "✅ Plan généré : ${TF_PLAN}"
                }
            }
        }

        stage('✅ Validation manuelle') {
            steps {
                input message: 'Appliquer le plan Terraform ?', ok: 'Oui, déployer'
            }
        }

        stage('🚀 Deploy - Application du plan') {
            steps {
                dir(env.TF_DIR) {
                    sh "terraform apply -auto-approve ${TF_PLAN}"
                    echo "✅ Infrastructure déployée"
                }
            }
        }

        stage('🧹 Optional Destroy') {
            when {
                expression { return params.DESTROY_INFRA }
            }
            steps {
                dir(env.TF_DIR) {
                    input message: 'Confirmer la destruction de l’infrastructure', ok: 'Détruire'
                    sh 'terraform destroy -auto-approve'
                }
            }
        }
    }

    post {
        success {
            echo "🎉 Pipeline terminé avec succès !"
        }
        failure {
            echo "❌ Échec du pipeline."
        }
    }
}
