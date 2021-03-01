from flask import *

app = Flask(__name__)

@app.route('/')
def index():
	return '<h1>{{name}}</h1>'

if __name__ == "__main__":
	app.run(debug=True, threaded=True, host='127.0.0.1', port=8080)
