# Ping!
This is the private repository for working on [Ping!](http://andonigarcia.github.io/Ping/static_websites/Website3)

## How to Set-Up
In order to set-up the Flask server and run the program, you must follow a couple easy steps.

1. Download the source files
2. In your terminal, change directories to the Ping root
3. Type `chmod a+x run.py`
4. Type `./run.py`
5. Navigate your browser to `localhost:5000`

## Troubleshooting
If you get an error about your database not running, follow these steps:

1. Type `chmod a+x db_create.py` at the root
2. Execute `./db_create.py`
3. Type `chmod a+x db_upgrade.py`
4. Execute `./db_upgrade.py`
