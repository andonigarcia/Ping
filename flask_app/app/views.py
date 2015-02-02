from app import app, db, lm
from datetime import datetime
from .emails import registration_notification
from flask import flash, g, jsonify, redirect, render_template, request, session, url_for  
from flask.ext.login import current_user, login_required, login_user, logout_user
from .forms import CompanyLoginForm, CompanyRegisterForm
from .models import Company, Ping
import re

def try_login(email, password):
	if email is None or email == "":
		return False
	company = Company.query.filter_by(email = email).first()
	if company is None:
		return False
	if company.check_password(str(password)):
		return True
	else:
		return False

def try_register(name, address1, address2, city, state, zipcode, phone, email):
	if name is None or name == "" or address1 is None or address1 == "" or city is None or city == "" or state is None or state == "" or zipcode is None or zipcode == "" or phone is None or phone == "" or email is None or email == "":
		return False
	exp1 = re.compile(r"[^a-zA-Z0-9\._\-\\ ]")
	match = re.search(exp1, name)
	if match:
		return False
	match = re.search(exp1, address1)
	if match:
		return False
	match = re.search(exp1, address2)
	if match:
		return False
	exp2 = re.compile(r"[^a-zA-Z \-]")
	match = re.search(exp2, city)
	if match:
		return False
	match = re.search(exp2, state)
	if match:
		return False
	exp3 = re.compile(r"[^0-9]")
	match = re.search(exp3, zipcode)
	if match:
		return False
	match = re.search(exp3, phone)
	if match:
		return False
	exp4 = re.compile(r"[a-zA-Z0-9_\.\-]+@[a-zA-Z0-9_\.\-]+\.[a-zA-Z0-9_]+")
	match = re.search(exp4, email)
	if not match:
		return False
	company = Company.query.filter_by(email = email).first()
	if company is not None:
		return False
	return True

@lm.user_loader
def load_user(id):
	return Company.query.get(int(id))

@app.before_request
def before_request():
	g.company = current_user

@app.route('/', methods = ['GET','POST'])
@app.route('/index', methods = ['GET','POST'])
def index():
	if g.company is not None and g.company.is_authenticated():
		return render_template('index.html')
	return render_template('about.html', title = "About Ping!")

@app.route('/team', methods = ['GET','POST'])
def team():
	return render_template('team.html', title = "Meet The Team")

@app.route('/about', methods = ['GET','POST'])
def about():
	return render_template('about.html', title = "About Ping!")

@app.route('/login', methods = ['GET','POST'])
def login():
	if g.company is not None and g.company.is_authenticated():
		return redirect(url_for('index'))
	form = CompanyLoginForm()
	if form.validate_on_submit():
		remember = form.remember_me.data
		session['remember_me'] = remember
		valid = try_login(form.email.data, form.password.data)
		if not valid:
			flash('Invalid Login. Please Try Again.')
			return redirect(url_for('login'))
		else:
			company = Company.query.filter_by(email = form.email.data).first()
			login_user(company, remember = remember)
			return redirect(request.args.get('next') or url_for('index'))
	return render_template('login.html', title = "Login", form = form)

@app.route('/logout', methods = ['GET','POST'])
@login_required
def logout():
	logout_user()
	return redirect(url_for('index'))

@app.route('/register', methods = ['GET','POST'])
def register():
	if g.company is not None and g.company.is_authenticated():
		return redirect(url_for('index'))
	form = CompanyRegisterForm()
	if form.validate_on_submit():
		name = form.name.data
		address1 = form.addr1.data
		address2 = form.addr2.data
		city = form.city.data
		state = form.state.data
		zipcode = form.zipcode.data
		phone = form.phone.data
		email = form.email.data
		valid = try_register(name, address1, address2, city, state, zipcode, phone, email)
		if not valid:
			flash('Invalid Registration. Please Try Again.')
			return redirect(url_for('register'))
		else:
			company = Company(name = name, address1 = address1, address2 = address2, city = city, state = state, zipcode = zipcode, phone = phone, email = email)
			company.add_password(str(form.pwd.data))
			company.timestamp = datetime.utcnow()
			db.session.add(company)
			db.session.commit()
			login_user(company, remember = False)
			return redirect(request.args.get('next') or url_for('index'))
	return render_template('register.html', title = "Register", form = form)

'''
@app.errorhandler(400)
def bad_request(error):
	return render_template('400.html'), 400

@app.errorhandler(404)
def not_found_error(error):
	return render_template('404.html'), 404

@app.errorhandler(500)
def internal_error(error):
	db.session.rollback()
	return render_template('500.html'), 500
'''