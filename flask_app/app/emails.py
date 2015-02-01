from app import app, mail
from config import ADMINS
from .decorators import async
from flask import render_template
from flask.ext.mail import Message

@async
def send_async_email(app, msg):
	with app.app_context():
		mail.send(msg)

def send_email(subject, sender, recipients, body, html):
	msg = Message(subject, sender = sender, recipients = recipients)
	msg.body = body
	msg.html = html
	send_async_email(app, msg)

def registration_notification(company):
	send_email("Thanks for registering with Ping!",
				ADMINS[0],
				[company.email],
				render_template("email/register_email.txt",
								company = company),
				render_template("email/register_email.html",
								company = company))
