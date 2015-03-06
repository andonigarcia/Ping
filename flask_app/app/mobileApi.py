from app import app, db, auth
from datetime import datetime
import errno
from flask import abort, flash, g, jsonify, redirect, render_template, request, session, url_for, send_from_directory
from flask.ext.login import current_user, login_required, login_user, logout_user
from .forms import UserLoginForm, UserRegisterForm
import os
from .models import Company, User
import random
import re

def verify_register(name, email, age, email_check, password = True):
	if name is None or name == "" or email is None or email == "" or age is None or password is None or password == "":
		return "One or more required fields is blank. Please check your responses and resubmit."
	exp1 = re.compile(r"[^a-zA-Z\._\- ]")
	match = re.search(exp1, name)
	if match:
		return "Your Name is invalid. We only allow letters, spaces and some punctuation."
	exp2 = re.compile(r"[a-zA-Z0-9_\.\-]+@[a-zA-Z0-9_\.\-]+\.[a-zA-Z0-9_]+")
	if age < 12 or age > 120:
		return "Your Age is invalid. Must be older than 12 years old."
	if password != True:
		if len(password) < 6:
			return "Your Password must be at least 6 characters long."
	match = re.search(exp2, email)
	if not match:
		return "Your Email Address is invalid. Please check to make sure you entered it correctly."
	if email_check:
		user = User.query.filter_by(email = email).first()
		if user is not None:
			return "This Email Address is already registered. Please register with a new one or login with this current one."
	return True

def get_deals(latlong):
	return None

@auth.verify_password
def verify_password(email, password):
	# Works because passwords must be 6 chars by client-side verification
	if password == "token":
		user = User.verify_token(email)
		if user is None:
			return False
		g.user = user
		return True
	else:
		user = User.query.filter_by(email = email).first()
		if not user or not user.check_password(password):
			return False
		g.user = user
		return True

# Returns Current Version's URI
@app.route('/mobile/api', methods = ['GET'])
def ApiCurrentVersion():
	return jsonify({'uri':'/mobile/api/v0.1/'})

# Where Login Page Should Route To
@app.route('/mobile/api/v0.1/token', methods = ['POST'])
@auth.login_required
def ApiLogin():
	token = g.user.generate_token()
	return jsonify({'token': token, 'user_id': g.user.id}), 200

# Where Register Page Should Route To
@app.route('/mobile/api/v0.1/users', methods = ['POST'])
def ApiRegister():
	username = request.json.get('name')
	email = request.json.get('email')
	age = request.json.get('age')
	password = request.json.get('password')
	error = verify_register(username, email, age, True, password)
	if error != True:
		abort(400, error)
	user = User(username = username, email = email, age = age)
	user.add_password(password)
	db.session.add(user)
	db.session.commit()
	token = user.generate_token()
	return jsonify({'token': token, 'user_id': user.id}), 201

# Where Settings Page Should Route To
@app.route('/mobile/api/v0.1/users/<int:id>', methods = ['GET'])
@auth.login_required
def ApiGetUser(id):
	if g.user.id != id:
		abort(403)
	username = g.user.username
	email = g.user.email
	age = g.user.age
	return jsonify({'username': username, 'email': email, 'age': age}), 200

# Where Settings Page Submit Should Route To
@app.route('/mobile/api/v0.1/users/<int:id>', methods = ['PUT'])
@auth.login_required
def ApiUpdateUser(id):
	if g.user.id != id:
		print(g.user.id, id)
		abort(403)
	username = request.json.get('name')
	email = request.json.get('email')
	age = request.json.get('age')
	email_check = True
	if email == g.user.email:
		email_check = False
	error = verify_register(username, email, age, email_check)
	if error != True:
		abort(400, error)
	g.user.username = username
	g.user.email = email
	g.user.age = age
	password = request.json.get('password')
	if password is not None and password != "" and len(password) >= 6:
		g.user.add_password(password)
	db.session.add(g.user)
	db.session.commit()
	token = g.user.generate_token()
	return jsonify({'token': token}), 200

# Where Map Page Should Route To
@app.route('/mobile/api/v0.1/users/<int:id>/map', methods = ['GET'])
@auth.login_required
def ApiUploadMap(id):
	if g.user.id != id:
		abort(403)
	latlong = request.json.get('location')
	if latlong is None or len(latlong) != 2:
		abort(400)
	deals = get_deals(latlong)
	return jsonify({'deals': deals}), 200

# Where Company Page Should Route To
@app.route('/mobile/api/v0.1/users/<int:id>/map/<int:companyid>', methods = ['GET'])
@auth.login_required
def ApiCompanyPage(id, companyid):
	if g.user.id != id:
		abort(403)
	company = Company.query.get(companyid)
	if not company:
		abort(400)
	deal = company.get_deal()
	return jsonify({'deal': deal}), 200

@app.route('/mobile/api/v0.1/users/<int:id>/map/<int:companyid>', methods = ['PUT'])
@auth.login_required
def ApiPreferenceUpdate(id, companyid):
	if g.user.id != id:
		abort(403)
	like = request.json.get('relevant')
	g.user.update_preference(companyid, like)
	db.session.add(g.user)
	db.session.commit()
	return jsonify({'success': True}), 200