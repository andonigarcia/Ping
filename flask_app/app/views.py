from app import app, db, lm
from config import SALT
from datetime import datetime
from .emails import registration_notification
from flask import flash, g, jsonify, redirect, render_template, request, session, url_for  
from flask.ext.login import current_user, login_required, login_user, logout_user
from .forms import CompanyLoginForm, CompanyRegisterForm
from .models import Company, Ping
'''
@lm.user_loader
def load_company(id):
	return Company.query.get(int(id))

@app.before_request
def before_request():
	g.company = current_user

@app.route('/', methods = ['GET', 'POST'])
@app.route('/index', methods = ['GET', 'POST'])
def index():
	render_template('index.html')

@app.route('/login', methods = ['GET', 'POST'])
def login():
	if g.company is not None and g.company.is_authenticated():
		return redirect(url_for('company'))
	form = CompanyLoginForm()
	if form.validate_on_submit():
		session['remember_me'] = form.remember_me.data
		email = form.email.data
		pwd = form.password.data
		if email is None or email == "":
			flash('Invalid login. Please try again.')
			return redirect(url_for('login'))
		company = Company.query.filter_by(email = form.email.data).first()
		if company is None:
			flash('Invalid login. Please try again.')
			return redirect(url_for('login'))
		if not company.check_password(form.password.data):
			flash('Invalid login. Please try again.')
			return redirect(url_for('login'))
		else:
			login_user(company, remember = form.remember_me.data)
			return redirect(url_for('company'), email = email)
	return render_template('login.html', form = form)

@app.route('/register')
def register():
	if g.company is not None and g.company.is_authenticated():
		return redirect(url_for('company'))
	form = CompanyRegisterForm()
	return render_template('register.html', form = form)

@app.route('/logout')
def logout():
	logout_user()
	return redirect(url_for('index'))

@app.route('/company')
@login_required
def company(email):
	company = Company.query.filter_by(email = email).first()
	return render_template('company.html')

@app.route('/team')
def team():
	return render_template('team.html')

@app.route('/about')
def about():
	return render_template('index.html')


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

@lm.user_loader
def load_user(id):
	return Company.query.get(int(id))

@app.before_request
def before_request():
	g.company = current_user

@app.route('/')
@app.route('/index')
def index():
	if g.company is not None and g.company.is_authenticated():
		return render_template('index.html')
	return render_template('about.html', title = "About Ping!")

@app.route('/team')
def team():
	return render_template('team.html', title = "Meet The Team")

@app.route('/about')
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

@app.route('/logout')
def logout():
	logout_user()
	return redirect(url_for('index'))

@app.route('/register')
def register():
	return render_template('register.html', title = "Register")