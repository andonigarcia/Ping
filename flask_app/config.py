import os
basedir = os.path.abspath(os.path.dirname(__file__))

# WTForms configus
WTF_CSRF_ENABLED = True
SECRET_KEY = '\xc5\x92W2\x0b\xc1\xddA\xbe\x1aR\n\xd7\xf9)\xc9\xa6\xbc\xf8\xaf\x1d\xb5d\x0c'

# Database configs
SQLALCHEMY_DATABASE_URI = 'sqlite:///' + os.path.join(basedir, 'app.db')
SQLALCHEMY_MIGRATE_REPO = os.path.join(basedir, 'db_repository')
WHOOSH_BASE = os.path.join(basedir, 'search.db')

# Email Server configs
MAIL_SERVER = 'smtp.googlemail.com'
MAIL_PORT = 465
MAIL_PORT = 465
MAIL_USE_TLS = False
MAIL_USE_SSL = True
MAIL_USERNAME = os.environ.get('MAIL_USERNAME')
MAIL_PASSWORD = os.environ.get('MAIL_PASSWORD')

# Administrator configs
ADMINS = ['andoni.m.garcia@gmail.com']

# Hash Salt
SALT = '\xd6"O|\x17\xa7\x0b\x87jV\xaf\x03B_h\xbd'