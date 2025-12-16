pipeline {
    agent any

    stages {
        stage('Clone Repository') {
            steps {
                // My github repos
                git branch: 'main', url: 'https://github.com/alphonse-r/two-tier-app.git'
            }
        }

        stage('Deploy Application with Docker Compose') {
            steps {
                // Arrêter les containers existants (si présents)
                sh 'docker compose down || true'

                // Lancer Flask + MySQL, reconstruire l'image Flask si nécessaire
                sh 'docker compose up -d --build'
            }
        }
    }
}
