# Ping!
This is the private repository for working on the Flask App of Ping.

## Installation/Setup

1. Install the newest version of [Python 2.7](https://www.python.org/downloads/).
2. Make sure [Pip](https://pip.pypa.io/en/latest/installing.html) is installed, by checking `pip --help`.
3. `git clone https://github.com/andonigarcia/Ping.git`
4. `cd Ping/flask_app`
5. Run `setup.sh` to install the needed dependencies and virtualenv the application.
  * If you get an error on this step, you might have to manually install [virtualenv](https://virtualenv.pypa.io/en/latest/installation.html).

## Running the Server

There are a couple ways to run the server, which range from lowest to highest in production-grade:

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

5. Dedicated Production Server

    ```$ ./runNet.py```

    Same rules apply as in (4), but you ought to go into the source code and change your IP to the desired host IP, entering in the credentials needed to login to the host server.

## Using the Server

There are two ways to interact with the server. 

The first is through the web application (meant as the company-side platform). To login to this:

  * On a development server, navigate your browser to `localhost:5000`
  * On a network server, navigate your browser to your server's public IP address, e.g. `10.150.24.244:5000`.  
    You can find your server's LAN information through `ipconfig`.
  * On a production server, navigate your browser to your your hosted domain URL.

You can also interact with the server through the REST API (meant for the user-side platform). The documentation for interacting with the API is below. It is intended as a private API for iOS-server interactions. Due to it's nature, it *can* act as a public API, but it is not meant to be.

## REST API

There are eight core API endpoints. Most of these require authentication, and will be identified appropriately. For each, I will give an example CURL request and response in order to understand how to write the HTTP headers and how the API responds.

  * **/mobile/api** - GET
    
    Gets the current API version's URI.  
    This endpoint does not require any body text nor authentication.  
    On success, it returns a status code 200, with a JSON response of: `{'uri':CURRENT_V_URI}`.  
    On failure, it returns a status code 400.

```

    $ curl -i http://localhost:5000/mobile/api
    HTTP/1.0 200 OK
	Content-Type: application/json
	Content-Length: 32
	Server: Werkzeug/0.10 Python/2.7.5
	Date: Fri, 06 Mar 2015 09:47:32 GMT
	
	{
	  "uri": "/mobile/api/v0.1/"
	}

```

  * **/mobile/api/v0.1/token** - POST

	Logs a user in.  
    This endpoint does not require any body text, but does require authentication in the header. Specifically, a username and password. See the CURL example for info on how to set up such a header.  
    On success, it returns a status code 200, with a JSON response of: `{'token': UNIQUE_LOGIN_TOKEN, 'user_id': UNIQUE_USER_ID}`.  
    On failure, it returns a status code 400.

    **Note:** Your application should store this token and user id. The user id will be necessary for accessing later end points. The token will be necessary for accessing any future endpoint with authentication requirements.

```

	$ curl -u andoni@uchicago.edu:password -i -X POST http://localhost:5000/mobile/api/v0.1/token
	HTTP/1.0 200 OK
	Content-Type: application/json
	Content-Length: 156
	Server: Werkzeug/0.10 Python/2.7.5
	Date: Fri, 06 Mar 2015 10:39:28 GMT
	
	{
	  "token": "eyJhbGciOiJIUzI1NiIsImV4cCI6MTQyNTg5NzU2OCwiaWF0IjoxNDI1NjM4MzY4fQ.eyJpZCI6MX0.oMHHi1_7qFuOgQiYD6nhsOMRGNWHCX2E8shP1EVQcyI",
	  "user_id": 1
	}
```

  * **/mobile/api/v0.1/users** - POST

    Registers a new user.  
    This endpoint requires the following JSON body: `{'name': USERNAME, 'email': EMAIL_ADDRESS, 'age': AGE, 'password': PASSWORD}`, but does not require authetication.  
    On success, it returns a status code 201, with a JSON response of: `{'token': UNIQUE_LOGIN_TOKEN, 'user_id': UNIQUE_USER_ID}`.  
    On failure, it returns a status code 400.

	**Note:** Your application should store this token and user id. The user id will be necessary for accessing later end points. The token will be necessary for accessing any future endpoint with authentication requirements.

```

	$ curl -i -X POST -H "Content-Type: application/json" -d '{"name":"Andoni Garcia", "email":"andoni@uchicago.edu", "age":20, "password":"andoni"}' http://localhost:5000/mobile/api/v0.1/users
	HTTP/1.0 201 CREATED
	Content-Type: application/json
	Content-Length: 158
	Server: Werkzeug/0.10 Python/2.7.5
	Date: Fri, 06 Mar 2015 10:21:24 GMT
	
	{
	  "token": "eyJhbGciOiJIUzI1NiIsImV4cCI6MTQyNTg5NjQ4NCwiaWF0IjoxNDI1NjM3Mjg0fQ.eyJpZCI6MX0.HEYC2m-GYahAFfVHbUiwOczVUTypRRC_q-rt-pAFHlE",
	  "user_id": "1"
	}

```

  * **/mobile/api/v0.1/users/<int:id>** - GET

    Gives the user's information. Meant to pre-populate the iOS settings page.  
    This endpoint does not require any body text, but does require authentication in the header. See the CURL for info on how to set up such a header.  
    On success, it returns a status code 200, with a JSON response of: `{'username': USERNAME, 'email': EMAIL, 'age': AGE}`.  
    On failure, it returns either a status code 400 or a status code 403 depending on the failure.

    **Note:** You can only GET the information of your own user. It will throw a 403 - Forbidden error if you try to access an endpoint with a different user id than the authentication token is for.

```

	$ curl -u eyJhbGciOiJIUzI1NiIsImV4cCI6MTQyNTg5NzU2OCwiaWF0IjoxNDI1NjM4MzY4fQ.eyJpZCI6MX0.oMHHi1_7qFuOgQiYD6nhsOMRGNWHCX2E8shP1EVQcyI:token -i http://localhost:5000/mobile/api/v0.1/users/1
	HTTP/1.0 200 OK
	Content-Type: application/json
	Content-Length: 82
	Server: Werkzeug/0.10 Python/2.7.5
	Date: Fri, 06 Mar 2015 10:41:29 GMT
	
	{
	  "age": 20,
	  "email": "andoni@uchicago.edu",
	  "username": "Andoni Garcia"
	}
```

  * **/mobile/api/v0.1/users/<int:id>** - PUT

    Updates a user's information.  
    This endpoint requires the following JSON body: `{'name': NAME, 'email': EMAIL, 'age': AGE, 'password': PASSWORD}`, and requires authentication in the header. The password field is optional, but the rest of the fields ought to either be prepopulated by the user's information, or hold the data of changed information to be commited to their model.  
    On success, it returns a status code of 200, with a JSON response of: `{'token': UNIQUE_LOGIN_TOKEN}`.  
    On failure, it returns either a status code 400 or a status code 403 depending on the failure.

    **Note:** You can only PUT information for your own user. It will throw a 403 - Forbidden error if you try to update an endpoint with a different user id than the authentication token is for.

```

	$ curl -u eyJhbGciOiJIUzI1NiIsImV4cCI6MTQyNTg5NjQ4NCwiaWF0IjoxNDI1NjM3Mjg0fQ.eyJpZCI6MX0.HEYC2m-GYahAFfVHbUiwOczVUTypRRC_q-rt-pAFHlE:token -i -X PUT -H "Content-Type: application/json" -d '{"name":"Andoni Garcia", "email":"andoni@uchicago.edu", "age":20, "password":"password"}' http://localhost:5000/mobile/api/v0.1/users/1
	HTTP/1.0 200 OK
	Content-Type: application/json
	Content-Length: 139
	Server: Werkzeug/0.10 Python/2.7.5
	Date: Fri, 06 Mar 2015 10:33:12 GMT
	
	{
	  "token": "eyJhbGciOiJIUzI1NiIsImV4cCI6MTQyNTg5NzE5MiwiaWF0IjoxNDI1NjM3OTkyfQ.eyJpZCI6MX0.6KBMN0-QbXEL9cFmqcnRafiuqIFFLkvO9deksR4cLKA"
	}
```

  * **/mobile/api/v0.1/users/<int:id>/map** - GET

    Gets current deals to populate a map UI.  
    This endpoint requires the following JSON body: `{'location': {'lat':LATITUDE, 'lng':LONGITUDE}}`, and requires authentication in the header. The latlong should be the user's center coordinates.  
    On success, it returns a status code of 200, with a JSON response of: `{'deal': LIST_OF_DEALS}`.  Each element in the LIST_OF_DEALS includes a JSON body, structured: `{'deal':DEAL_MESSAGE, 'id':UNIQUE_COMPANY_ID, 'info':COMP_INFO, 'latlong':{'lat':LATITUDE, 'lng':LONGITUDE}}`.
    On failure, it returns either a status code 400 or a status code 403 depending on the failure.

```

  $ curl -u eyJhbGciOiJIUzI1NiIsImV4cCI6MTQyNTk1Nzc1MSwiaWF0IjoxNDI1Njk4NTUxfQ.eyJpZCI6MX0.3rYg0g1sZLtwZkbbFImscmYz7UmvAS0dd1CEnVDUDOw:token -i -X GET -H "Content-Type: application/json" -d '{"location":{"lat":41.78992, "lng":-87.59248}}' http://localhost:5000/mobile/api/v0.1/users/1/map
  HTTP/1.0 200 OK
  Content-Type: application/json
  Content-Length: 921
  Server: Werkzeug/0.10 Python/2.7.5
  Date: Sat, 07 Mar 2015 03:19:30 GMT

  {
    "deals": [
      {
        "deal": "TEEESSSTTTTING!",
        "id": 1,
        "info": {
          "address1": "1358 E. 58th St.",
          "address2": "Apt. #1",
          "city": "Chicago",
          "logo": "/static/img/companies/1/logo.jpg?v=5681",
          "name": "Andoni Inc.",
          "phone": "760-845-8667",
          "state": "IL",
          "zipcode": "60637"
        },
        "latlong": {
          "lat": 41.789916,
          "lng": -87.592457
        }
      },
      {
        "deal": "50% Now until tomorrow!",
        "id": 2,
        "info": {
          "address1": "1174 E 55th St.",
          "address2": "",
          "city": "Chicago",
          "logo": "/static/img/companies/2/logo.png?v=1668",
          "name": "Starbucks",
          "phone": "111-222-3333",
          "state": "IL",
          "zipcode": "60615"
        },
        "latlong": {
          "lat": 41.7951856,
          "lng": -87.59674179999999
        }
      }
    ]
  }
```

  * **/mobile/api/v0.1/users/<int:id>/map/<int:companyid>** - GET

    Gets the information for a company's current deal. Meant to be used to populate a deal's page.  
    This endpoint does not require a body text, but does require authentication in the header.  
    On success, it returns a status code of 200, with a JSON response of: `{'deal': DEAL}`, a DEAL consists of: `{'deal': DEAL_MESSAGE, 'id': UNIQUE_COMPANY_ID, 'info': COMPANY_INFO, 'latlong': {'lat': LATITUDE, 'lng': LONGITUDE}}`  
    On failure, it returns either a status code 400 or a status code 403 depending on the failure.

```

  $ curl -u eyJhbGciOiJIUzI1NiIsImV4cCI6MTQyNTk1Nzc1MSwiaWF0IjoxNDI1Njk4NTUxfQ.eyJpZCI6MX0.3rYg0g1sZLtwZkbbFImscmYz7UmvAS0dd1CEnVDUDOw:token -i -X GET -H "Content-Type: application/json" -d '{"location":{"lat":41.78992, "lng":-87.59248}}' http://localhost:5000/mobile/api/v0.1/users/1/map/2
  HTTP/1.0 200 OK
  Content-Type: application/json
  Content-Length: 428
  Server: Werkzeug/0.10 Python/2.7.5
  Date: Sat, 07 Mar 2015 03:23:37 GMT

  {
    "deal": {
      "deal": "50% Now until tomorrow!",
      "id": 2,
      "info": {
        "address1": "1174 E 55th St.",
        "address2": "",
        "city": "Chicago",
        "logo": "/static/img/companies/2/logo.png?v=1668",
        "name": "Starbucks",
        "phone": "111-222-3333",
        "state": "IL",
        "zipcode": "60615"
      },
      "latlong": {
        "lat": 41.7951856,
        "lng": -87.59674179999999
      }
    }
  }
```

  * **/mobile/api/v0.1/users/<int:id>/map/<int:companyid>** - PUT

    Updates user's preferences.  
    This endpoint requires a JSON body consisting of: `{'relevant': BOOLEAN}` and requires authentication in the header.  
    On success, it returns a status code of 200, with a JSON response of: `{'success': True}`.  
    On failure, it returns either a status code 400 or a status code 403 depending on the failure.

```

	$ curl -u eyJhbGciOiJIUzI1NiIsImV4cCI6MTQyNTg5NzU2OCwiaWF0IjoxNDI1NjM4MzY4fQ.eyJpZCI6MX0.oMHHi1_7qFuOgQiYD6nhsOMRGNWHCX2E8shP1EVQcyI:token -i -X PUT -H "Content-Type: application/json" -d '{"relevant":true}' http://localhost:5000/mobile/api/v0.1/users/1/map/1
	HTTP/1.0 200 OK
	Content-Type: application/json
	Content-Length: 21
	Server: Werkzeug/0.10 Python/2.7.5
	Date: Fri, 06 Mar 2015 10:48:53 GMT
	
	{
	  "success": true
	}
```

## Change Log

**v0.1** - Initial release.

## Still Todo:
Updated - 3/12/15 - Andoni Garcia

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
  * Lat/long distance percision
2. Models Functionality:
  * Users.update_preferences

-AMG