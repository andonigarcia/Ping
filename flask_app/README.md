# Ping!
This is the private repository for working on [Ping!](http://andonigarcia.github.io/Ping/static_websites/Website3)

## How to Set-Up
In order to set-up the Flask server and run the program, you must follow a couple easy steps.

1. Download the source files
2. In your terminal, change directories to the Ping root
3. Type `chmod a+x run.py`
4. If you are running in production mode, you must enter your email credentials (otherwise registration won't work):
  * Type `MAIL_USERNAME='x' MAIL_PASSWORD='y' ./run.py` where x is your gmail username and y is your password
5. Else, if you are not running in production mode:
  * Type `./run.py`
6. Navigate your browser to `localhost:5000`

## Troubleshooting
If you get an error about your database not running, follow these steps:

1. Type `chmod a+x db_create.py` at the root
2. Execute `./db_create.py`
3. Type `chmod a+x db_upgrade.py`
4. Execute `./db_upgrade.py`

### Update - 2/4/15 - Andoni Garcia
Still Todo:

1. Forms: CSS. Errors. Bad 5-char zip not handled
2. Informative registration errors.
3. Make a robust company page
  * Include a map
  * Include abilities to post Pings
  * Include payment processing
  * Include analytics
4. Bring the CSS up-to-date
5. Make CSS mobile friendly
6. Reformat each Picture to the same size
7. Ping! Logo => Design and make SVG
8. Favicon and iPhone icons...ugh I need a design day soon
9. Landing Page! :D Interactive app? PICTURES! Infographics.
10. Before production switch to a MySQL server (most likely when we set up an Apache server too, create the full LAMP stack)

-AMG
