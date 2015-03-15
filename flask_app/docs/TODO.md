# Ping Collaborative To-Do List

Updated - 13 March 2015 - Andoni Garcia

## Web App

1. Company Page:
  * Analytics and Payments tabs
  * Forms.js is acting funny -- See line 13
  * Make responsive
  * Update/refine Pings models
2. Errors:
  * Google Maps:
    Not found addresses/problems with Geocode are not handled
  * Pings Tab:
    I hacked out the refresh to same tab function. Reloading no longer works if you've already submit a Ping.
3. CSS:
  * Forms:
  	- **Bug**: Click between help fields leads to build up of <br /> tags
    - **Bug**: First click/offclick on a help field doesn't <br /> the two notifications
  * About:
    - In any founder's page, if you click it will underline everything
  * Everywhere:
    - Make the site mobile friendly (if not mobile first)
4. Design:
  * Ping! Logo.
  * iPhone icons
5. Landing Page:
  * Interactive wireframe?
6. Stripe:
  * We should open up a new html tab with a receipt after paying
  * Integrate our keys and stuff (account is under my email and password)
  * Create a variable payment strucutre and really solidify the CSS/HTML for paying.
7. From live test, check the following:
  * Registration corner cases
  * Do not underline subheaders for the company page
  * Switch Lobster Two to Philosopher

## REST API

1. API Functionality:
  * Delete old tokens. Look into how to do this.
  * Lat/long distance percision
2. Models Functionality:
  * Users.update_preferences
3. SSL Cert

-AMG