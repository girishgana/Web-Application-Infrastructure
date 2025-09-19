
# app/app.py
from flask import Flask
import os
import psycopg2

app = Flask(__name__)

def get_db_time():
    try:
        conn = psycopg2.connect(
            host=os.environ.get("DB_HOST"),
            user=os.environ.get("DB_USER"),
            password=os.environ.get("DB_PASS"),
            dbname=os.environ.get("DB_NAME", "appdb"),
            connect_timeout=5
        )
        cur = conn.cursor()
        cur.execute("SELECT now()")
        row = cur.fetchone()
        cur.close()
        conn.close()
        return f"DB time: {row[0]}"
    except Exception as e:
        return f"DB error: {e}"

@app.route("/")
def index():
    return f"Hello from Flask! {get_db_time()}"

@app.route("/health")
def health():
    return "OK", 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=int(os.environ.get("PORT", 8080)))

