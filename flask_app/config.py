# -*- coding: utf8 -*-
import os
basedir = os.path.abspath(os.path.dirname(__file__))

# WTForms configus
WTF_CSRF_ENABLED = True
SECRET_KEY = '\xc5\x92W2\x0b\xc1\xddA\xbe\x1aR\n\xd7\xf9)\xc9\xa6\xbc\xf8\xaf\x1d\xb5d\x0c'

# Database configs
if os.environ.get('DATABASE_URL') is None:
    SQLALCHEMY_DATABASE_URI = 'sqlite:///' + os.path.join(basedir, 'app.db')
else:
    SQLALCHEMY_DATABASE_URI = os.environ['DATABASE_URL']
SQLALCHEMY_MIGRATE_REPO = os.path.join(basedir, 'db_repository')
SQLALCHEMY_RECORD_QUERIES = True

# Email Server configs
MAIL_SERVER = 'smtp.googlemail.com'
MAIL_PORT = 465
MAIL_PORT = 465
MAIL_USE_TLS = False
MAIL_USE_SSL = True
MAIL_USERNAME = os.environ.get('MAIL_USERNAME')
MAIL_PASSWORD = os.environ.get('MAIL_PASSWORD')

# Administrator configs
ADMINS = ['weareping@gmail.com']

# File Uploads
UPLOAD_FOLDER = 'app/static/img/companies/'
IMG_FOLDER = '/static/img/companies/'

# Stripe Account Info
if os.environ.get('STRIPE_SECRET_KEY') is None or os.environ.get('STRIPE_PUBLISHABLE_KEY') is None:
	STRIPE_KEYS = {'secret_key':'sk_test_qSz9zN80HUYIs8LUTQLusMUr',
					'publishable_key':'pk_test_g7sfm1OgkGdcZqcGZY7DzVxe'}
else:
	STRIPE_KEYS = {'secret_key':os.environ.get('STRIPE_SECRET_KEY'),
					'publishable_key':os.environ.get('STRIPE_PUBLISHABLE_KEY')}