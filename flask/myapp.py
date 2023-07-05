from flask import Flask, jsonify
import logging
import sys

app = Flask(__name__)

# Configure logging to send logs to the standard output
logging.basicConfig(stream=sys.stdout, level=logging.INFO)

# Health check endpoint
@app.route('/health')
def health_check():
    return jsonify({'status': 'ok'})

@app.route('/')
def hello_world():
    return jsonify({"message": "Hello, World!"})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)

print("Hello, World!")