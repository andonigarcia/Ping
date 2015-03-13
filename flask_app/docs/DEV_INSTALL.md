# Ping Development Server Installation Instructions
Andoni M. Garcia
13 March 2015

## Installation/Setup

1. Install the newest version of [Python 2.7](https://www.python.org/downloads/).
2. Make sure [Pip](https://pip.pypa.io/en/latest/installing.html) is installed, by checking `pip --help`.
3. `git clone https://github.com/andonigarcia/Ping.git`
4. `cd Ping/flask_app`
5. Run `setup.sh` to install the needed dependencies and virtualenv the application.
  * If you are running on a UNIX-based machine, you might need sudo privileges. As such, run `setupSudo.sh`.
  * If you get an error on this step, you might have to manually install [virtualenv](https://virtualenv.pypa.io/en/latest/installation.html). (Debian based machines cannot `pip install virtualenv`)

## Running the Server

There are a couple ways to run the server, which range from lowest to highest in networked development servers:

1. Debug Mode

    ```$ ./run.py```

2. Debug Mode w/Email Support

    ```$ MAIL_USERNAME='yourAct@gmail.com' MAIL_PASSWORD='yourPass' ./run.py```

    Where the username and password are the gmail credentials of your preferred ADMIN account

3. Debug Mode w/Payment Processing:

    ```$ STRIPE_PUBLISHABLE_KEY='pk_test_g7sfm1OgkGdcZqcGZY7DzVxe' STRIPE_SECRET_KEY='sk_test_qSz9zN80HUYIs8LUTQLusMUr' ./run.py```

    If you are testing the Stripe payments, the test credentials are: Credit card number: `4242 4242 4242 4242`, with any CVC and expiry date in the future. You can combine this with the above Email Support to have a fully functional development application. 

4. Network Server

    ```$ ./runNet.py```

    When running this network server with any of the above email or payment processing support, you should enter in production-level account information. The email and password of the production ADMIN email and the publishable/secret keys of your private production Stripe account. Ask your WebAdmin for this if you do not have access to it.

5. Dedicated Network Server

    ```$ ./runNet.py```

    Same rules apply as in (4), but you ought to go into the source code and change your IP to the desired host IP, making sure the DNS routing matches.  

    If you are looking to deploy your application, please don't run this step as your production-grade server. Flask is a microframework and as such does not have the server capacity to establish mutexes, run proper threading, handle network connectivity, load-balance, or properly serve a large amount of connections. If you are ever expecting anything greater than 10-20 connections at a time, look into DEPLOYMENT.md for running on an Apache server. All of these methods are for **development servers**.

## Using the Server

There are two ways to interact with the server. 

The first is through the web application (meant as the company-side platform). To login to this:

  * On a localhosted server, navigate your browser to `localhost:5000`
  * On a networked server, navigate your browser to your server's public IP address, e.g. `10.150.24.244:5000`.  
    You can find your server's LAN information through `ipconfig` or `ifconfig` depending on OS.

You can also interact with the server through the REST API (meant for the user-side platform). The documentation for interacting with the API is in the REST_API.md document. It is intended as a private API for iOS-server interactions. Due to it's nature, it *can* act as a public API, but it is not meant to be. It's endpoints are accessed through the base-URI from above.