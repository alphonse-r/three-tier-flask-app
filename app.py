from flask import Flask, render_template, request, redirect, url_for
import MySQLdb
import os
import time

# Config DB depuis les variables d'environnement
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

def wait_for_db():
    """Attendre que MySQL soit prêt avant de lancer l'application"""
    while True:
        try:
            conn = get_db_connection()
            conn.close()
            print("MySQL est prêt !")
            break
        except MySQLdb.OperationalError:
            print("Attente de MySQL...")
            time.sleep(2)

def create_table_if_not_exists():
    """Créer la table person si elle n'existe pas"""
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute("""
        CREATE TABLE IF NOT EXISTS person (
            id INT AUTO_INCREMENT PRIMARY KEY,
            name VARCHAR(255) NOT NULL
        )
    """)
    conn.commit()
    cur.close()
    conn.close()


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


if __name__ == "__main__":
    wait_for_db()              # Attendre MySQL
    create_table_if_not_exists()  # Créer table si nécessaire
    app.run(host="0.0.0.0", port=5000)
