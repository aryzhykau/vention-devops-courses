from flask import Flask, jsonify
import logging
from pythonjsonlogger import jsonlogger
import os
import socket

# Configure logging
logger = logging.getLogger()
logHandler = logging.StreamHandler()
formatter = jsonlogger.JsonFormatter()
logHandler.setFormatter(formatter)
logger.addHandler(logHandler)
logger.setLevel(logging.INFO)

app = Flask(__name__)

@app.route('/')
def home():
    logger.info('Received request for home page')
    return jsonify({
        'message': 'Welcome to ECS Demo App',
        'hostname': socket.gethostname()
    })

@app.route('/health')
def health():
    return jsonify({'status': 'healthy'})

@app.route('/metadata')
def metadata():
    return jsonify({
        'hostname': socket.gethostname(),
        'environment': os.environ.get('ENVIRONMENT', 'development'),
        'region': os.environ.get('AWS_REGION', 'unknown')
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=80) 