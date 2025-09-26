# app/app.py
import os
import psycopg2
from flask import Flask, render_template

app = Flask(__name__)

DB_HOST = os.environ.get("DB_HOST")
DB_PORT = int(os.environ.get("DB_PORT", 5432))
DB_NAME = os.environ.get("DB_NAME")
DB_USER = os.environ.get("DB_USER")
DB_PASS = os.environ.get("DB_PASS")

def get_db_connection():
    conn = psycopg2.connect(
        host=DB_HOST,
        port=DB_PORT,
        user=DB_USER,
        password=DB_PASS,
        dbname=DB_NAME
    )
    return conn

@app.route("/")
def index():
    rows = []
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute("CREATE TABLE IF NOT EXISTS visits (id serial PRIMARY KEY, msg text, ts timestamptz DEFAULT now());")
        cur.execute("INSERT INTO visits (msg) VALUES (%s) RETURNING my_id;", ("Hello from Flask",))
        conn.commit()
        cur.execute("SELECT id, msg, ts FROM visits ORDER BY ts DESC LIMIT 10;")
        rows = cur.fetchall()
        cur.close()
        conn.close()
    except Exception as e:
        rows = [("error", str(e), "")]
    return render_template("index.html", rows=rows)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
