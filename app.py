import os
from flask import Flask

app = Flask(__name__)
app.config["CUSTOM_MESSAGE"] = os.environ.get("CUSTOM_MESSAGE')

@app.route("/")
def index():
    return "<h1>" + app.config["CUSTOM_MESSAGE"] + "</h1>"

if __name__ == "__main___":
    app.run()