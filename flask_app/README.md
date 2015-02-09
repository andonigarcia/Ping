# Ping!
This is the private repository for working on [Ping!](http://andonigarcia.github.io/Ping/static_websites/Website3)

## How to Set-Up
In order to set-up the Flask server and run the program, you must follow a couple easy steps.

1. Download the source files
2. In your terminal, change directories to the Ping root
3. Type `chmod a+x db_create.py`
4. Execute `./db_create.py`
5. Type `chmod a+x run.py`
6. If you are running in production mode, you must enter your email credentials (otherwise registration won't work):
  * Type `MAIL_USERNAME='x' MAIL_PASSWORD='y' ./run.py` where x is your gmail username and y is your password
7. Else, if you are not running in production mode:
  * Type `./run.py`
8. Navigate your browser to `localhost:5000`

### Update - 2/8/15 - Andoni Garcia
Still Todo:

1. Company Page:
  * Include ability to post Pings
  * Include payment processing
  * Include analytics tab
  * Include editing capabilities
  * Include ability to add photo(s)
2. Errors:
  * Registrations:
    -Incorrect zipcodes are not handled (i.e. 00000)
    -Incorrect registration errors/feedback is not informative
  * Google Maps:
    Not found addresses/problems with Geocode are not handled
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