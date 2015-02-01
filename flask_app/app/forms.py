from flask.ext.wtf import Form
from .models import Company
from wtforms import StringField, BooleanField, TextAreaField
from wtforms.validators import DataRequired, Length

class CompanyLoginForm(Form):
	email = StringField('CompanyEmail', validators = [DataRequired()])
	password = StringField('CompanyPwd', validators = [DataRequired()])
	remember_me = BooleanField('CompanyRemember', default = False)

class CompanyRegisterForm(Form):
	name = StringField('CompanyName', validators = [DataRequired()])
	addr1 = StringField('CompanyAddr1', validators = [DataRequired()])
	addr2 = StringField('CompanyAddr2')
	city = StringField('CompanyCity', validators = [DataRequired()])
	state = StringField('CompanyState', validators = [DataRequired()])
	zipcode = StringField('CompanyZipcode', validators = [DataRequired()])
	phone = StringField('CompanyPhone', validators = [DataRequired()])
	email = StringField('CompanyEmail', validators = [DataRequired()])
	pwd = StringField('CompanyPwd', validators = [DataRequired()])

	def __init__(self, email, *args, **kwargs):
		Form.__init__(self, *args, **kwargs)
		self.email = email

	# Still need to validate each field
	def validate(self):
		if not Form.validate(self):
			return False
		company = Company.query.filter_by(email = self.email.data).first()
		if company is not None:
			self.email.errors.append('This email is already registered.')
			return False
		return True