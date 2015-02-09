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
  * If you a running in production mode, you must enter your gmail credentials of your ADMIN account. As such, let x be your gmail username and y your password. Then type `MAIL_USERNAME='x@gmail.com' MAIL_PASSWORD='y' ./run.py`
  * Else, if you are just testing, run the server by `./run.py`
9. Navigate your browser to `localhost:5000`

* Note, in order to deploy and run on a dedicated network, you must change line 3 of run.py to `app.run(debug = False, host='0.0.0.0')`

## Still Todo:
Updated - 2/8/15 - Andoni Garcia

1. Company Page:
  * Include payment processing
  * Include analytics tab
  * Include editing capabilities
  * Include ability to add photo(s)
  * Don't show old Pings (whose time is expired)
2. Errors:
  * Registrations:
    -Incorrect zipcodes are not handled (i.e. 00000)
    -Incorrect registration errors/feedback is not informative
  * Google Maps:
    Not found addresses/problems with Geocode are not handled
  * Posting Pings:
    -Informative feedback (i.e. error: endTime < startTime)
3. CSS:
  * Forms:
  	- Disable submit button until client-side validation is finished
  * Meet the Team:
    - Make pictures the same size
  * Everywhere:
    - Update new classes/tags. I haven't touched CSS since starting work
      on the server.
    - Make the site mobile friendly (if not mobile first)
4. Design:
  * Ping! Logo.
  * Favicon and iPhone icons
5. Landing Page:
  * Interactive wireframe? More Pictures, Less Words.
6. Server:
  * Set up a LAMP stack. Deploy to a domain.

-AMG