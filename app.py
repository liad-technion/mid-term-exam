import os
import socket
from flask import Flask, jsonify, redirect, render_template, request
from dotenv import load_dotenv
load_dotenv()

API_KEY = os.environ.get("API_KEY")
if not API_KEY:
    raise RuntimeError("API_KEY is required")

VERSION = os.environ.get("VERSION", "1.0.0")
PORT = int(os.environ.get("PORT", "5000"))

app = Flask(__name__)


@app.get("/")
def index():
    return render_template("index.html")


@app.get("/api/status")
def status_alias():
    return redirect("/api/v1/status", code=302)


@app.get("/api/secret")
def secret_alias():
    return redirect("/api/v1/secret", code=302)


@app.get("/api/v1/status")
def status():
    return jsonify(status="ok", hostname=socket.gethostname(), version=VERSION)


@app.get("/api/v1/secret")
def secret():
    if request.headers.get("X-API-Key") != API_KEY:
        return jsonify(error="unauthorized"), 401
    return jsonify(message="you found the secret")


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=PORT)