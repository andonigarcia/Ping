# Ping!
This is the private repository for working on the Flask App of Ping.

## Installation/Setup

1. Install the newest version of [Python 2.7](https://www.python.org/downloads/).
2. Download this source code and unzip it.
3. In your terminal, change directories to the Ping root
3. Run `setup.sh` to install the needed dependencies and virtualenv the application.
  * If you get an error on this step, you might have to manually install [virtualenv](https://virtualenv.pypa.io/en/latest/installation.html).

## Running the Server

There are a couple ways to run the server, which range from lowest to highest in production-grade:

1. Debug Mode

    `$ ./run.py`

2. Debug Mode w/Email Support

    `$ MAIL_USERNAME='yourAct@gmail.com' MAIL_PASSWORD='yourPass' ./run.py`

  - Where the username and password are the gmail credentials of your preferred ADMIN account
3. Debug Mode w/Payment Processing:

    `$ STRIPE_PUBLISHABLE_KEY='pk_test_g7sfm1OgkGdcZqcGZY7DzVxe' STRIPE_SECRET_KEY='sk_test_qSz9zN80HUYIs8LUTQLusMUr' ./run.py`

  - You can combine this with the above Email Support to have a fully functional development application

4. Network Server

    `$ ./runNet.py`

  - When running this network server with any of the above email or payment processing support, you should enter in production-level account information. The email and password of the production ADMIN email and the publishable/secret keys of your private production Stripe account. Ask your WebAdmin for this if you do not have access to it.

5. Dedicated Production Server

    `$ ./runNet.py`

  - Same rules apply as in (4), but you ought to go into the source code and change your IP to the desired host IP, entering in the credentials needed to login to the host server.

## Using the Server

There are two ways to interact with the server. The easiest is the web application (meant for companies). To login to this:
  * On a development server, navigate your browser to `localhost:5000`
  * On a network server, navigate your browser to your server's public IP address, e.g. `10.150.24.244:5000`. You can find your server's LAN information through `ipconfig`.
  * On a production server, navigate your browser to your your given domain URL.

You can also interact with the server through the REST API (meant for iOS/mobile applications and users). The documentation for this will come.

PS: If you are testing the Stripe payments, the test credentials are: Credit card number: `4242 4242 4242 4242`, with any CVC and expiry date in the future.

## Still Todo:
Updated - 3/5/15 - Andoni Garcia

### Web App

1. Company Page:
  * Analytics and Payments tabs
  * Forms.js is acting funny -- See line 13
  * When Submitting a Ping, try to refresh to ping tab
  * Make responsive
  * When uploading new logo, integrate a preview
  * Update/refine Pings models
2. Errors:
  * Google Maps:
    Not found addresses/problems with Geocode are not handled
3. CSS:
  * Forms:
  	- **Bug**: Click between help fields leads to build up of <br /> tags
    - **Bug**: First click/offclick on a help field doesn't <br /> the two notifications
  * Pings:
    - JQuery Datetime plugin
  * Everywhere:
    - Make the site mobile friendly (if not mobile first)
4. Design:
  * Ping! Logo.
  * iPhone icons
5. Landing Page:
  * Interactive wireframe? More Pictures, Less Words.
6. Stripe:
  * We should open up a new html tab with a receipt after paying
  * Integrate our keys and stuff (account is under my email and password)
  * Create a variable payment strucutre and really solidify the CSS/HTML for paying.
7. Server:
  * Set up a LAMP stack. Deploy to a domain.
8. From live test, check the following:
  * Png and jpg image support.
  * Registration corner cases
  * Do not underline subheaders for the company page
  * Switch Lobster Two to Philosopher

### REST API

1. API Functionality:
  * Delete old tokens. Look into how to do this.
  * get_deals implementation!
  * Move most functionality to models (oops, breaking the MVC contract. Fuck you patriarchy!)
2. Models Functionality:
  * Users.update_preferences
  * Company.get_deal
  * A LOT of company-pings relationship functionality
3. iOS implementation
  * JSON responses, proper HTTP requests, handling
4. Documentation!
5. Testing!

-AMG