#!Flask/bin/python
import os

os.environ['DATABASE_URL'] = 'mysql://ping:ping@localhost/ping'

from flipflop import WSGIServer
from app import app

if __name__ == '__main__':
	WSGIServer(app).run()