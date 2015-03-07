from app import app, db
from datetime import datetime
from itsdangerous import BadSignature, SignatureExpired, TimedJSONWebSignatureSerializer as Serializer
from passlib.apps import custom_app_context as pwd_context
from sqlalchemy import func
from urllib import quote_plus
from urllib2 import Request, urlopen
import json
import math
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
	longitude = db.Column(db.Float)
	latitude = db.Column(db.Float)
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

	def add_latlng(self, dic):
		self.latitude = dic['lat']
		self.longitude = dic['lng']
		return True

	@staticmethod
	def verify_address(address):
		url = "http://maps.googleapis.com/maps/api/geocode/json?address="
		url += quote_plus(address)
		req = Request(url)
		response = json.loads(urlopen(req).read().decode('utf-8'))
		if response['status'] != "OK":
			return False
		return response['results'][0]['geometry']['location']

	# Center must be a tuple (lat, long) and radius be in miles
	@staticmethod
	def nearby_companies(center, radius):
		latDist = float(radius) / 69
		lngDist = abs(latDist / math.cos(center[0]))
		print(latDist, lngDist)
		arr = Company.query.filter(func.abs(Company.latitude - center[0]) < latDist).filter(func.abs(Company.longitude - center[1]) < lngDist).all()
		print(arr)
		return [{'latlong': {'lat':x.latitude, 'lng':x.longitude}, 'info': 	{'name':x.name, 'address1':x.address1, 'address2':x.address2, 'city':x.city, 'state':x.state, 'zipcode':x.zipcode, 'phone':x.phone, 'logo':x.logo}} for x in arr]

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

	def update_preference(self, companyid, like):
		if like:
			pass
		else:
			pass

	# Verification Functions
	@staticmethod
	def verify_username(username):
		if username is None or len(username) < 2:
			return False
		if re.search(r"[^a-zA-Z'\._\- ]", username):
			return False
		return True

	@staticmethod
	def verify_email(email):
		if email is None or len(email) < 6:
			return False
		if re.search(r"\S+@\S+\.[a-zA-Z]{2,}", email):
			return False
		return True

	@staticmethod
	def verify_unique_email(email):
		user = User.query.filter_by(email = email).first()
		if user is not None:
			return False
		return True

	@staticmethod
	def verify_password(password):
		if password is None or len(password) < 6:
			return False
		return True

	@staticmethod
	def verify_age(age):
		if age < 13 or age > 120:
			return False
		return True

	@staticmethod
	def verify_token(token):
		serial = Serializer(app.config['SECRET_KEY'])
		try:
			response = serial.loads(token)
		except SignatureExpired:
			return None
		except BadSignature:
			return None
		user = User.query.get(response['id'])
		if user is None:
			return None
		else:
			return user

	def __repr__(self):
		return '<User %r>' % (self.email)