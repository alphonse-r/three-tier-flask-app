docker --version
docker compose version
cat <<"EOF" > DockerfileJ
# Jenkins LTS officiel
FROM jenkins/jenkins:lts-slim-jdk21

# Passe en root pour installer des packages
USER root

# Installer Git et Docker CLI + Docker Compose v2
RUN apt-get update && \
    apt install git && \
    curl -fsSL https://get.docker.com -o get-docker.sh && \
    sh get-docker.sh && \
    rm -rf /var/lib/apt/lists/*

# Retour à l’utilisateur jenkins
USER jenkins
EOF

ls
docker build -t jenkins-with-docker-git -f DockerfileJ .
docker run -d   --name jenkins   -p 8080:8080 -p 50000:50000   -v jenkins_home:/var/jenkins_home   -v /var/run/docker.sock:/var/run/docker.sock   --group-add $(getent group docker | cut -d: -f3)   jenkins-with-docker-git
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
ls
mkdir -p templates/index.html
mkdir -p static/style.css
cat <<"EOF" > app.py
from flask import Flask, render_template, request, redirect, url_for
import MySQLdb
import os

DB_HOST = os.environ.get("DB_HOST", "localhost")
DB_USER = os.environ.get("DB_USER", "flaskuser")
DB_PASSWORD = os.environ.get("DB_PASSWORD", "flaskpass")
DB_NAME = os.environ.get("DB_NAME", "devops")

app = Flask(__name__)

def get_db_connection():
    return MySQLdb.connect(
        host=DB_HOST,
        user=DB_USER,
        passwd=DB_PASSWORD,
        db=DB_NAME
    )

@app.route("/", methods=["GET", "POST"])
def index():
    conn = get_db_connection()
    cur = conn.cursor()

    # Ajouter une personne
    if request.method == "POST":
        name = request.form.get("name")
        if name:
            cur.execute("INSERT INTO person (name) VALUES (%s)", (name,))
            conn.commit()

    # Récupérer toutes les personnes
    cur.execute("SELECT id, name FROM person")
    persons = cur.fetchall()

    cur.close()
    conn.close()

    return render_template("index.html", persons=persons)

@app.route("/delete/<int:id>")
def delete_person(id):
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute("DELETE FROM person WHERE id = %s", (id,))
    conn.commit()
    cur.close()
    conn.close()
    return redirect(url_for("index"))

@app.route("/edit/<int:id>", methods=["POST"])
def edit_person(id):
    new_name = request.form.get("name")
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute("UPDATE person SET name = %s WHERE id = %s", (new_name, id))
    conn.commit()
    cur.close()
    conn.close()
    return redirect(url_for("index"))

@app.route("/health")
def health():
    return "OK", 200
EOF

cat <<"EOF" > static/style.css
body {
    font-family: Arial, sans-serif;
    background-color: #f4f6f8;
    padding: 30px;
}

h2 {
    color: #333;
}

.container {
    background: white;
    padding: 20px;
    border-radius: 6px;
    max-width: 600px;
    margin: auto;
    box-shadow: 0 2px 6px rgba(0,0,0,0.1);
}

form {
    margin-bottom: 20px;
}

input[type="text"] {
    padding: 8px;
    width: 200px;
    margin-right: 10px;
}

button {
    padding: 8px 12px;
    border: none;
    border-radius: 4px;
    cursor: pointer;
    color: white;
}

.btn-add {
    background-color: #28a745; /* vert */
}

.btn-edit {
    background-color: #007bff; /* bleu */
}

.btn-delete {
    background-color: #dc3545; /* rouge */
}

ul {
    list-style: none;
    padding: 0;
}

li {
    background: #fafafa;
    padding: 10px;
    margin-bottom: 8px;
    display: flex;
    align-items: center;
    justify-content: space-between;
    border-radius: 4px;
}

.actions {
    display: flex;
    gap: 5px;
}

.edit-form {
    display: flex;
    gap: 5px;
}
EOF

ls
cat static/style.css
cd static
ls
cd styles.css
cd style.css
cd ../..
rm -r static
rm -r templates
ls
mkdir templates/index.html
clear
sudo apt update && sudo apt upgrade -y
sudo apt install git
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
newgrp docker
