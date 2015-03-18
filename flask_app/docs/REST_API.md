# Ping - REST API

Propriatary Information Here Follows.

Andoni M. Garcia
18 March 2015

## Documentation

There are eight core API endpoints. Most of these require authentication, and will be identified appropriately. For each, I will give an example CURL request and response in order to understand how to write the HTTP headers and how the API responds.

  * **/mobile/api** - GET
    
    Gets the current API version's URI.  
    This endpoint does not require any body text nor authentication.  
    On success, it returns a status code 200, with a JSON response of: `{'uri':CURRENT_V_URI}`.  
    On failure, it returns a status code 400.

```
  $ curl -i http://www.igotpinged.com/mobile/api
  HTTP/1.1 200 OK
  Date: Wed, 18 Mar 2015 20:37:16 GMT
  Server: Apache/2.2.29 (Amazon)
  Content-Length: 32
  Connection: close
  Content-Type: application/json

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
  $ curl -u andoni@uchicago.edu:password -i -X POST http://www.igotpinged.com/mobile/api/v0.1/token
  HTTP/1.1 200 OK
  Date: Wed, 18 Mar 2015 20:39:10 GMT
  Server: Apache/2.2.29 (Amazon)
  Content-Length: 156
  Connection: close
  Content-Type: application/json

  {
    "token": "eyJhbGciOiJIUzI1NiIsImV4cCI6MTQyNjk3MDM1MCwiaWF0IjoxNDI2NzExMTUwfQ.eyJpZCI6MX0.0B1dQ-3Po_MeJIGnHhTourUO6TX-OQAYABgS0rK8rwA",
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
  $ curl -i -X POST -H "Content-Type: application/json" -d '{"name":"Tony Stark", "email":"tony@starkenterprise.com", "age":42, "password":"IAmIronman!"}' http://www.igotpinged.com/mobile/api/v0.1/users
  HTTP/1.1 201 CREATED
  Date: Wed, 18 Mar 2015 20:41:58 GMT
  Server: Apache/2.2.29 (Amazon)
  Content-Length: 156
  Connection: close
  Content-Type: application/json

  {
    "token": "eyJhbGciOiJIUzI1NiIsImV4cCI6MTQyNjk3MDUxOCwiaWF0IjoxNDI2NzExMzE4fQ.eyJpZCI6Nn0.d_2NukPlTf9gNgx2FcBY8Cv9mYA3ETa8N0CTvvlKxOg",
    "user_id": 6
  }
```

  * **/mobile/api/v0.1/users/<int:id>** - GET

    Gives the user's information. Meant to pre-populate the iOS settings page.  
    This endpoint does not require any body text, but does require authentication in the header. See the CURL for info on how to set up such a header.  
    On success, it returns a status code 200, with a JSON response of: `{'username': USERNAME, 'email': EMAIL, 'age': AGE}`.  
    On failure, it returns either a status code 400 or a status code 403 depending on the failure.

    **Note:** You can only GET the information of your own user. It will throw a 403 - Forbidden error if you try to access an endpoint with a different user id than the authentication token is for.

```
  $ curl -u eyJhbGciOiJIUzI1NiIsImV4cCI6MTQyNjk3MDUxOCwiaWF0IjoxNDI2NzExMzE4fQ.eyJpZCI6Nn0.d_2NukPlTf9gNgx2FcBY8Cv9mYA3ETa8N0CTvvlKxOg:token -i http://www.igotpinged.com/mobile/api/v0.1/users/6
  HTTP/1.1 200 OK
  Date: Wed, 18 Mar 2015 20:43:48 GMT
  Server: Apache/2.2.29 (Amazon)
  Content-Length: 84
  Connection: close
  Content-Type: application/json

  {
    "age": 42,
    "email": "tony@starkenterprise.com",
    "username": "Tony Stark"
  }
```

  * **/mobile/api/v0.1/users/<int:id>** - PUT

    Updates a user's information.  
    This endpoint requires the following JSON body: `{'name': NAME, 'email': EMAIL, 'age': AGE, 'password': PASSWORD}`, and requires authentication in the header. The password field is optional, but the rest of the fields ought to either be prepopulated by the user's information, or hold the data of changed information to be commited to their model.  
    On success, it returns a status code of 200, with a JSON response of: `{'token': UNIQUE_LOGIN_TOKEN}`.  
    On failure, it returns either a status code 400 or a status code 403 depending on the failure.

    **Note:** You can only PUT information for your own user. It will throw a 403 - Forbidden error if you try to update an endpoint with a different user id than the authentication token is for.

```
  $ curl -u eyJhbGciOiJIUzI1NiIsImV4cCI6MTQyNjk3MDUxOCwiaWF0IjoxNDI2NzExMzE4fQ.eyJpZCI6Nn0.d_2NukPlTf9gNgx2FcBY8Cv9mYA3ETa8N0CTvvlKxOg:token -i -X PUT -H "Content-Type: application/json" -d '{"name":"Tony Stark", "email":"tony@starkenterprise.com", "age":35}' http://www.igotpinged.com/mobile/api/v0.1/users/6
  HTTP/1.1 200 OK
  Date: Wed, 18 Mar 2015 20:46:20 GMT
  Server: Apache/2.2.29 (Amazon)
  Content-Length: 139
  Connection: close
  Content-Type: application/json

  {
    "token": "eyJhbGciOiJIUzI1NiIsImV4cCI6MTQyNjk3MDc4MCwiaWF0IjoxNDI2NzExNTgwfQ.eyJpZCI6Nn0.RqwjtaBNS_K8g7XMr1ifjP2WqSnYBYf2Rqv3e9rwzyk"
  }
```

  * **/mobile/api/v0.1/users/<int:id>/map** - GET, PUT

    Gets current deals to populate a map UI.  
    This endpoint requires the following JSON body: `{'lat':LATITUDE, 'lng':LONGITUDE}`, and requires authentication in the header. The latlong should be the user's center coordinates.  
    On success, it returns a status code of 200, with a JSON response of: `{'deal': LIST_OF_DEALS}`.  Each element in the LIST_OF_DEALS includes a JSON body, structured: `{'deal':DEAL_MESSAGE, 'id':UNIQUE_COMPANY_ID, 'info':COMP_INFO, 'latlong':{'lat':LATITUDE, 'lng':LONGITUDE}}`.
    On failure, it returns either a status code 400 or a status code 403 depending on the failure.

    **Note:** Because of some iOS connectivity issues, this endpoint now accepts PUT requests too. The GET is also now usable from a browser setting. I will show one of each responses below.

```
  $ curl -u eyJhbGciOiJIUzI1NiIsImV4cCI6MTQyNjk3MDUxOCwiaWF0IjoxNDI2NzExMzE4fQ.eyJpZCI6Nn0.d_2NukPlTf9gNgx2FcBY8Cv9mYA3ETa8N0CTvvlKxOg:token -i -X PUT -H "Content-Type: application/json" -d '{"lat":41.78992, "lng":-87.59248}' http://www.igotpinged.com/mobile/api/v0.1/users/6/map
  HTTP/1.1 200 OK
  Date: Wed, 18 Mar 2015 20:49:28 GMT
  Server: Apache/2.2.29 (Amazon)
  Content-Length: 473
  Connection: close
  Content-Type: application/json

  {
    "deals": [
      {
        "deal": "FREE STARBUCKS",
        "id": 2,
        "info": {
          "address1": "1174 E. 55th St.",
          "address2": "",
          "city": "Chicago",
          "logo": "/static/img/companies/2/logo.png?v=5792",
          "name": "Starbuck's",
          "phone": "111-222-33",
          "state": "IL",
          "zipcode": "60615"
        },
        "latlong": {
          "lat": 41.795200000000001,
          "lng": -87.596699999999998
        }
      }
    ]
  }
```

    Also, the endpoint can be accessed through a GET request (e.g. through a browser):

```
  $ curl -u eyJhbGciOiJIUzI1NiIsImV4cCI6MTQyNjk3MDUxOCwiaWF0IjoxNDI2NzExMzE4fQ.eyJpZCI6Nn0.d_2NukPlTf9gNgx2FcBY8Cv9mYA3ETa8N0CTvvlKxOg:token -i "http://www.igotpinged.com/mobile/api/v0.1/users/6/map?lat=41.78992&lng=-87.59248"
  HTTP/1.1 200 OK
  Date: Wed, 18 Mar 2015 20:50:52 GMT
  Server: Apache/2.2.29 (Amazon)
  Content-Length: 473
  Connection: close
  Content-Type: application/json

  {
    "deals": [
      {
        "deal": "FREE STARBUCKS",
        "id": 2,
        "info": {
          "address1": "1174 E. 55th St.",
          "address2": "",
          "city": "Chicago",
          "logo": "/static/img/companies/2/logo.png?v=5792",
          "name": "Starbuck's",
          "phone": "111-222-33",
          "state": "IL",
          "zipcode": "60615"
        },
        "latlong": {
          "lat": 41.795200000000001,
          "lng": -87.596699999999998
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
  $ curl -u eyJhbGciOiJIUzI1NiIsImV4cCI6MTQyNjk3MDUxOCwiaWF0IjoxNDI2NzExMzE4fQ.eyJpZCI6Nn0.d_2NukPlTf9gNgx2FcBY8Cv9mYA3ETa8N0CTvvlKxOg:token -i http://www.igotpinged.com/mobile/api/v0.1/users/6/map/2
  HTTP/1.1 200 OK
  Date: Wed, 18 Mar 2015 20:52:02 GMT
  Server: Apache/2.2.29 (Amazon)
  Content-Length: 428
  Connection: close
  Content-Type: application/json

  {
    "deal": {
      "deal": "FREE STARBUCKS",
      "id": 2,
      "info": {
        "address1": "1174 E. 55th St.",
        "address2": "",
        "city": "Chicago",
        "logo": "/static/img/companies/2/logo.png?v=5792",
        "name": "Starbuck's",
        "phone": "111-222-33",
        "state": "IL",
        "zipcode": "60615"
      },
      "latlong": {
        "lat": 41.795200000000001,
        "lng": -87.596699999999998
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
  $ curl -u eyJhbGciOiJIUzI1NiIsImV4cCI6MTQyNjk3MDUxOCwiaWF0IjoxNDI2NzExMzE4fQ.eyJpZCI6Nn0.d_2NukPlTf9gNgx2FcBY8Cv9mYA3ETa8N0CTvvlKxOg:token -i -X PUT -H "Content-Type: application/json" -d '{"relevant":true}' http://www.igotpinged.com/mobile/api/v0.1/users/6/map/2
  HTTP/1.1 200 OK
  Date: Wed, 18 Mar 2015 20:53:35 GMT
  Server: Apache/2.2.29 (Amazon)
  Content-Length: 21
  Connection: close
  Content-Type: application/json

  {
    "success": true
  }
```

## Change Log

**v0.1** - Initial release.