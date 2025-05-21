from flask import Flask, jsonify
import os
import platform
import psutil
import time
import uuid

app = Flask(__name__)

@app.route('/')
def index():
    return jsonify({
        "message": "Привет из Python приложения!",
        "hostname": platform.node(),
        "platform": platform.system(),
        "uuid": str(uuid.uuid4()),
        "timestamp": time.time()
    })

@app.route('/health')
def health():
    return jsonify({
        "status": "healthy",
        "memory_usage": {
            "total": psutil.virtual_memory().total,
            "available": psutil.virtual_memory().available,
            "percent": psutil.virtual_memory().percent
        },
        "cpu_usage": psutil.cpu_percent(interval=1)
    })

@app.route('/env')
def environment():
    return jsonify({
        "environment_variables": dict(os.environ)
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True) 