from app import app, db
from datetime import datetime
from itsdangerous import BadSignature, SignatureExpired, TimedJSONWebSignatureSerializer as Serializer
from passlib.apps import custom_app_context as pwd_context
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
	logo = db.Column(db.String(100))
	pings = db.relationship('Ping', backref = 'company', lazy = 'dynamic')

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

	def current_pings(self):
		return Ping.query.filter(Ping.company_id == self.id).filter(Ping.endTime > datetime.utcnow())

	def get_deal(self):
		return None

	def check_password(self, string):
		if pwd_context.verify(string, self.password):
			return True
		else:
			return False

	def add_password(self, string):
		self.password = pwd_context.encrypt(string)
		return True

	def __repr__(self):
		return '<Company %r>' % (self.email)

class Ping(db.Model):
	id = db.Column(db.Integer, primary_key = True)
	message = db.Column(db.String(150))
	timestamp = db.Column(db.DateTime)
	startTime = db.Column(db.DateTime)
	endTime = db.Column(db.DateTime)
	company_id = db.Column(db.Integer, db.ForeignKey('company.id'))

	def __repr__(self):
		return '<Ping %r>' % (self.message)

class User(db.Model):
	id = db.Column(db.Integer, primary_key = True)
	username = db.Column(db.String(150))
	email = db.Column(db.String(150), index = True, unique = True)
	password = db.Column(db.String(64))
	age = db.Column(db.Integer, index = True)
	timestamp = db.Column(db.DateTime)

	def get_id(self):
		try:
			return unicode(self.id)  # for Python 2
		except NameError:
			return str(self.id)  # for Python 3

	def check_password(self, string):
		if pwd_context.verify(string, self.password):
			return True
		else:
			return False

	def add_password(self, string):
		self.password = pwd_context.encrypt(string)
		return True

	def generate_token(self, expiration = 60 * 60 * 24 * 3):  # 3 Day Token
		serial = Serializer(app.config['SECRET_KEY'], expires_in = expiration)
		return serial.dumps({'id': self.id})

	@staticmethod
	def verify_token(token):
		serial = Serializer(app.config['SECRET_KEY'])
		try:
			response = s.loads(token)
		except SignatureExpired:
			return None
		except BadSignature:
			return None
		user = User.query.get(response['id'])
		if user is None:
			return None
		else:
			return user

	def update_preference(self, companyid, like):
		if like:
			pass
		else:
			pass

	def __repr__(self):
		return '<User %r>' % (self.email)