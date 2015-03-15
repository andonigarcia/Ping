from app import app, db, lm, ALLOWED_EXTENSIONS, STRIPE_KEYS
from datetime import datetime
from .emails import registration_notification
import errno
from flask import flash, g, jsonify, redirect, render_template, request, session, url_for, send_from_directory
from flask.ext.login import current_user, login_required, login_user, logout_user
from .forms import CompanyLoginForm, CompanyRegisterForm, PingForm, ImageUpload, CompanyEditForm
import os
from .models import Company, Ping
import random
import re
import stripe
from werkzeug import secure_filename

stripe.api_key = "sk_test_qSz9zN80HUYIs8LUTQLusMUr"

def try_login(email, password):
	if email is None or email == "":
		return False
	company = Company.query.filter_by(email = email).first()
	if company is None:
		return False
	if company.check_password(str(password)):
		return True
	return False

def try_register(name, address1, address2, city, state, zipcode, phone, email, email_check, password = True):
	if not Company.verify_name(name):
		return "Your Company Name is invalid. We only allow numbers, letters, spaces and some punctuation."
	if not Company.verify_addr1(address1):
		return "Your Address 1 field is invalid. We only allow numbers, letters, spaces and some punctuation."
	if not Company.verify_addr2(address2):
		return "Your Address 2 field is invalid. We only allow numbers, letters, spaces and some punctuation."
	if not Company.verify_city(city):
		return "Your City field is invalid. We only allow letters, spaces and hyphens. Please check your ZipCode."
	if not Company.verify_state(state):
		return "Your state field is invalid. We only two letter State abbreviations. Please check your ZipCode."
	if not Company.verify_zipcode(zipcode):
		return "Your ZipCode is invalid. Please check to make sure you didn't enter the wrong Zip."
	if not Company.verify_phone(phone):
		return "Your Phone Number does not match our specification. Please enter your 10 digit hyphenated Phone Number."
	if not Company.verify_email(email):
		return "Your Email Address is invalid. Please check to make sure you entered it correctly."
	if email_check:
		if not Company.verify_unique_email(email):
			return "This Email Address is already registered. Please register with a new one or login with this current one."
	if password != True:
		if not Company.verify_password(password):
			return "Your Password is invalid. Please make sure it is 6+ characters in length."
	return True

def try_post(message, start, end):
	if len(message) > 150:
		return "Your Ping! must be less than 150 characters! Please try to shorten it."
	if end < start:
		return "You can't have an End Time before your Start Time! Please correct this and resubmit your Ping!"
	return True

def allowed_file(filename):
	return '.' in filename and filename.rsplit('.', 1)[1] in ALLOWED_EXTENSIONS

def make_directory(dir):
	path = os.path.dirname(dir)
	if not os.path.exists(path):
		try:
			os.makedirs(path)
		except OSError as exception:
			if exception.errno != errno.EEXIST:
				raise

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
		return redirect(url_for('company'))
	return render_template('landing.html')

@app.route('/team', methods = ['GET','POST'])
def team():
	return render_template('team.html', title = "Meet The Team")

@app.route('/about', methods = ['GET','POST'])
def about():
	return render_template('about.html', title = "About Ping!")

@app.route('/landing', methods = ['GET', 'POST'])
def landing():
	return render_template('landing.html')

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
			flash('Invalid Login Credentials. Please Try Again.')
			return redirect(url_for('login'))
		else:
			company = Company.query.filter_by(email = form.email.data).first()
			login_user(company, remember = remember)
			return redirect(request.args.get('next') or url_for('company'))
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
		password = form.pwd.data
		isError = try_register(name, address1, address2, city, state, zipcode, phone, email, True, password)
		if isError != True:
			flash(isError)
			return redirect(url_for('register'))
		latlng = Company.verify_address(address1 + ', ' + city + ', ' + state + ' ' + zipcode)
		if latlng == False:
			flash("Address Could Not Be Verified via Google Maps.")
			return redirect(url_for('register'))
		else:
			company = Company(name = name, address1 = address1, address2 = address2, city = city, state = state, zipcode = zipcode, phone = phone, email = email)
			company.add_password(password)
			company.add_latlng(latlng)
			company.timestamp = datetime.utcnow()
			db.session.add(company)
			db.session.commit()
			registration_notification(company)
			login_user(company, remember = False)
			return redirect(url_for('company'))
	return render_template('register.html', title = "Register", form = form)

@app.route('/company', methods = ['GET', 'POST'])
@login_required
def company():
	form = PingForm()
	form2 = CompanyEditForm()
	formImg = ImageUpload()
	if form.validate_on_submit():
		message = form.message.data
		startTime = form.start.data
		endTime = form.end.data
		start = datetime.strptime(startTime, "%Y-%m-%dT%H:%M")
		end = datetime.strptime(endTime, "%Y-%m-%dT%H:%M")
		isError = try_post(message, start, end)
		if isError != True:
			flash(isError)
			return redirect(url_for('company'))
		else:
			ping = Ping(message = message, startTime = start, endTime = end, impressions = 0, engagements = 0)
			ping.timestamp = datetime.utcnow()
			ping.company = g.company
			db.session.add(ping)
			db.session.commit()
			return redirect(url_for('company'))
	if form2.validate_on_submit():
		address1 = form2.addr1.data
		address2 = form2.addr2.data
		city = form2.city.data
		state = form2.state.data
		zipcode = form2.zipcode.data
		phone = form2.phone.data
		email = form2.email.data
		isError2 = try_register(g.company.name, address1, address2, city, state, zipcode, phone, email, False)
		if isError2 != True:
			flash(isError2)
			return redirect(url_for('company'))
		latlng = Company.verify_address(address1 + ', ' + city + ', ' + state + ' ' + zipcode)
		if latlng == False:
			flash("Address Could Not Be Google Maps Verified.")
			return redirect(url_for('register'))
		else:
			g.company.address1 = address1
			g.company.address2 = address2
			g.company.city = city
			g.company.state = state
			g.company.zipcode = zipcode
			g.company.add_latlng(latlng)
			g.company.phone = phone
			g.company.email = email
			db.session.add(g.company)
			db.session.commit()
			return redirect(url_for('company'))
	if formImg.validate_on_submit():
		if not formImg.image.data:
			flash("File was empty. Please check your source.")
			return redirect(url_for('company'))
		else:
			file = request.files['image']
			if file:
				if allowed_file(file.filename):
					init_cwd = os.path.join(os.getcwd(), app.config['UPLOAD_FOLDER'])
					add_cmpny = os.path.join(init_cwd, str(g.company.id))
					filename = '/logo.' + file.filename.rsplit('.', 1)[1]
					filedir = add_cmpny + filename
					make_directory(filedir)
					open(filedir, 'w').write(file.read())
					imgEnding = str(g.company.id) + filename + "?v=" + str(random.randint(1,10000))
					imgLocation = os.path.join(app.config['IMG_FOLDER'], imgEnding)
					g.company.logo = imgLocation
					db.session.add(g.company)
					db.session.commit()
					return redirect(url_for('company'))
				else:
					flash("Your file name raised an error. Please reformat your file to standard image formatting.")
					redirect(url_for('company'))
			else:
				flash("No file was found! Please check your input!")
				redirect(url_for('company'))
	else:
		form2.addr1.data = g.company.address1
		form2.addr2.data = g.company.address2
		form2.city.data = g.company.city
		form2.state.data = g.company.state
		form2.zipcode.data = g.company.zipcode
		form2.phone.data = g.company.phone
		form2.email.data = g.company.email
	return render_template('company.html', title = g.company.name, form = form, form2 = form2, formImg = formImg, key = STRIPE_KEYS['publishable_key'])

@app.route('/charge', methods = ['POST'])
@login_required
def charge():
	amount = 500
	customer = stripe.Customer.create(
		email = g.company.email,
		card = request.form['stripeToken'])
	charge = stripe.Charge.create(
		customer = customer.id,
		amount = amount,
		currency = 'usd',
		description = 'Flask Test Charge')
	return render_template('charge.html', amount = amount, description = description)

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