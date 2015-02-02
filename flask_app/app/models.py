from app import app, db
from config import SALT
from hashlib import sha256
import re
import sys

class Company(db.Model):
	id = db.Column(db.Integer, primary_key = True)
	name = db.Column(db.String(150), index = True)
	address1 = db.Column(db.String(150), index = True)
	address2 = db.Column(db.String(150), index = True)
	city = db.Column(db.String(150), index = True)
	state = db.Column(db.String(2), index = True)
	zipcode = db.Column(db.String(5), index = True)
	phone = db.Column(db.String(10), index = True)
	email = db.Column(db.String(150), index = True, unique = True)
	password = db.Column(db.String(64))
	timestamp = db.Column(db.DateTime)
	pings = db.relationship('Ping', backref = 'company', lazy = 'dynamic')

	@staticmethod
	def make_valid_email(email):
		return re.sub('^[a-zA-Z0-9_\.]+@[a-zA-Z0-9_.]+\.[a-zA-Z0-9_]+', '', email)

	#Todo validate the rest of the fields...

	def is_authenticated(self):
		return True

	def is_active(self):
		return True

	def is_anonymous(self):
		return False

	def get_id(self):
		try:
			return unicode(self.id)  # for Python 2
		except NameError:
			return str(self.id)  # for Python 3

	def check_password(self, string):
		string += SALT
		tmpCheck = sha256(string).hexdigest()
		if tmpCheck == self.password:
			return True
		else:
			return False

	def __repr__(self):
		return '<Company %r>' % (self.email)

class Ping(db.Model):
	id = db.Column(db.Integer, primary_key = True)
	message = db.Column(db.String(150))
	timestamp = db.Column(db.DateTime)
	duration = db.Column(db.DateTime)
	company_id = db.Column(db.Integer, db.ForeignKey('company.id'))

	def __repr__(self):
		return '<Ping %r>' % (self.message)