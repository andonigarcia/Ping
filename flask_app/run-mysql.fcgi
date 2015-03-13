#!Flask/bin/python
import os

os.environ['DATABASE_URL'] = 'mysql://<username>:<password>@localhost/<db_name>'
#os.environ['MAIL_USERNAME'] = <GMAIL USERNAME>
#os.environ['MAIL_PASSWORD'] = <GMAIL PASSWORD>
#os.environ['STRIPE_PUBLISHABLE_KEY'] = <STRIP PUBLISHABLE KEY>
#os.environ['STRIPE_SECRET_KEY'] = <STRIPE SECRET KEY>

from flup.server.fcgi import WSGIServer
from app import app

if __name__ == '__main__':
	WSGIServer(app).run()