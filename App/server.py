from flask import Flask, render_template, request, redirect
from flask_mail import Mail, Message
from dotenv import load_dotenv
import os
import csv

load_dotenv()

app = Flask(__name__)

app.config['MAIL_SERVER'] = 'smtp.gmail.com'
app.config['MAIL_PORT'] = 587
app.config['MAIL_USE_TLS'] = True
app.config['MAIL_USE_SSL'] = False
app.config['MAIL_USERNAME'] = os.getenv('MAIL_USERNAME')
app.config['MAIL_PASSWORD'] = os.getenv('MAIL_PASSWORD')
mail = Mail(app)


@app.route('/')
def home():
    return render_template('index.html')


@app.route('/<string:page_name>')
def html_page(page_name):
    return render_template(page_name)


def write_to_csv(data):
    with open('database.csv', mode='a', newline='') as database:
        email = data["email"]
        name = data["name"]
        message = data["message"]
        csv_writer = csv.writer(database, delimiter=',',
                                quotechar='"', quoting=csv.QUOTE_MINIMAL)
        csv_writer.writerow([name, email, message])


@app.route('/submit_form', methods=['POST', 'GET'])
def login():
    if request.method == 'POST':
        data = request.form.to_dict()
        name = data["name"]
        email = data["email"]
        message = data["message"]
        write_to_csv(data)
        msg = Message(
            subject=f"Mail from {name}", body=f"Name: {name}\nEmail: {email}\n\n {message}", sender="aayanb134@gmail.com", recipients=['aayanb134@gmail.com'])
        mail.send(msg)
        return render_template('/thankyou.html', name=name)
    else:
        return redirect('/nope.html')


if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
