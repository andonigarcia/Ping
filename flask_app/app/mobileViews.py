from app import app, db, lm
from datetime import datetime
import errno
from flask import flash, g, jsonify, redirect, render_template, request, session, url_for, send_from_directory
from flask.ext.login import current_user, login_required, login_user, logout_user
from .forms import UserLoginForm, UserRegisterForm
import os
from .models import Company, User
import random
import re

def try_login(email, password):
	if email is None or email == "":
		return False
	company = User.query.filter_by(email = email).first()
	if company is None:
		return False
	if company.check_password(str(password)):
		return True
	else:
		return False

def try_register(name, email, email_check):
	if name is None or name == "" or email is None or email == "":
		return "One or more required fields is blank. Please check your responses and resubmit."
	exp1 = re.compile(r"[^a-zA-Z\._\- ]")
	match = re.search(exp1, name)
	if match:
		return "Your Company Name is invalid. We only allow letters, spaces and some punctuation."
	exp2 = re.compile(r"[a-zA-Z0-9_\.\-]+@[a-zA-Z0-9_\.\-]+\.[a-zA-Z0-9_]+")
	match = re.search(exp2, email)
	if not match:
		return "Your Email Address is invalid. Please check to make sure you entered it correctly."
	if email_check:
		user = User.query.filter_by(email = email).first()
		if user is not None:
			return "This Email Address is already registered. Please register with a new one or login with this current one."
	return True

@lm.user_loader
def load_user(id):
	return User.query.get(int(id))

@app.before_request
def before_request():
	g.user = current_user

@app.route('/mobile/', methods = ['GET','POST'])
@app.route('/mobile/index', methods = ['GET','POST'])
def index():
	if g.user is not None and g.user.is_authenticated():
		return redirect(url_for('user'))
	return 'Welcome To Ping!'

@app.route('/mobile/login', methods = ['GET','POST'])
def login():
	if g.user is not None and g.user.is_authenticated():
		return redirect(url_for('map'))
	form = UserLoginForm()
	if form.validate_on_submit():
		remember = form.remember_me.data
		session['remember_me'] = remember
		valid = try_login(form.email.data, form.password.data)
		if not valid:
			flash('Invalid Login Credentials. Please Try Again.')
			return redirect(url_for('login'))
		else:
			user = User.query.filter_by(email = form.email.data).first()
			login_user(user, remember = remember)
			return redirect(request.args.get('next') or url_for('map'))
	return 'Login!'

@app.route('/mobile/logout', methods = ['GET','POST'])
@login_required
def logout():
	logout_user()
	return redirect(url_for('index'))

@app.route('/mobile/register', methods = ['GET','POST'])
def register():
	if g.user is not None and g.user.is_authenticated():
		return redirect(url_for('index'))
	form = UserRegisterForm()
	if form.validate_on_submit():
		name = form.name.data
		email = form.email.data
		isError = try_register(name, email, True)
		if isError != True:
			flash(isError)
			return redirect(url_for('register'))
		else:
			user = User(username = name, email = email)
			user.add_password(str(form.pwd.data))
			user.timestamp = datetime.utcnow()
			db.session.add(user)
			db.session.commit()
			login_user(user, remember = False)
			return redirect(url_for('map'))
	return 'Register!'

@app.route('/mobile/company', methods = ['GET', 'POST'])
@login_required
def company(company, ping):
	return render_template('company.html', company = company, ping = ping)

@app.route('/mobile/map', methods = ['GET', 'POST'])
@login_required
def map():
	return 'Map!'