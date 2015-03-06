# Ping!
This is the private repository for working on [Ping!](http://andonigarcia.github.io/Ping/static_websites/Website3)

## How to Set-Up
In order to set-up and run the Flask server:

1. Download the source files
2. In your terminal, change directories to the Ping root
3. Type `chmod a+x db_create.py`
4. Execute `./db_create.py`
5. Type `chmod a+x db_migrate.py`
6. Execute `./db_migrate.py`
7. Type `chmod a+x run.py`
8. Running the server:
  * To just play around with the general site, run the server by `./run.py`
  * If you a running in production mode, you must enter your gmail credentials of your ADMIN account. As such, let x be your gmail username and y your password. Then type `MAIL_USERNAME='x@gmail.com' MAIL_PASSWORD='y' ./run.py`
  * If you want to test the Stripe payment functionality, you also need to include to environment variables: `STRIPE_PUBLISHABLE_KEY=pk_test_g7sfm1OgkGdcZqcGZY7DzVxe STRIPE_SECRET_KEY=sk_test_qSz9zN80HUYIs8LUTQLusMUr ./run.py` in addition to your email credentials
9. Navigate your browser to `localhost:5000`
10. If you are testing the Stripe payments, the test credentials are: Credit card number: `4242 4242 4242 4242`, with any CVC and expiry date in the future.

* Note, in order to deploy and run on a dedicated network, either execute `runNet.py` or change the host of `runNet.py` to your desired host IP.

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