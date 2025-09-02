
import os
import psycopg2
from flask import Flask, jsonify

app = Flask(__name__)

def get_db_config():
    # Prefer Secrets Manager JSON env (injected via CI or sidecar) or individual env vars
    secret_json = os.getenv("DB_SECRET_JSON")
    if secret_json:
        import json
        cfg = json.loads(secret_json)
        return {
            "host": cfg.get("host") or os.getenv("DB_HOST"),
            "port": cfg.get("port", 5432),
            "dbname": cfg.get("dbname") or os.getenv("DB_NAME", "appdb"),
            "user": cfg.get("username") or os.getenv("DB_USER", "appuser"),
            "password": cfg.get("password") or os.getenv("DB_PASSWORD")
        }
    return {
        "host": os.getenv("DB_HOST"),
        "port": int(os.getenv("DB_PORT", "5432")),
        "dbname": os.getenv("DB_NAME", "appdb"),
        "user": os.getenv("DB_USER", "appuser"),
        "password": os.getenv("DB_PASSWORD"),
    }

@app.route("/healthz")
def healthz():
    return "ok", 200

@app.route("/")
def index():
    cfg = get_db_config()
    try:
        conn = psycopg2.connect(
            host=cfg["host"], port=cfg["port"],
            dbname=cfg["dbname"], user=cfg["user"],
            password=cfg["password"], connect_timeout=3
        )
        cur = conn.cursor()
        cur.execute("""
            CREATE TABLE IF NOT EXISTS messages(
                id SERIAL PRIMARY KEY,
                content TEXT NOT NULL
            );
        """)
        conn.commit()
        cur.execute("INSERT INTO messages(content) VALUES('Hello from Flask + Postgres!') RETURNING id;")
        conn.commit()
        cur.execute("SELECT id, content FROM messages ORDER BY id DESC LIMIT 5;")
        rows = cur.fetchall()
        cur.close()
        conn.close()
        return jsonify({"status": "ok", "rows": [{"id": r[0], "content": r[1]} for r in rows]})
    except Exception as e:
        return jsonify({"status": "error", "error": str(e), "cfg": {**cfg, "password":"***"}}), 500

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=int(os.getenv("PORT", "8080")))
