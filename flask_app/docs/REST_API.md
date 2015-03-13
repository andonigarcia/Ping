# Ping - REST API

Propriatary Information Here Follows.

Andoni M. Garcia
13 March 2015

## Documentation

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