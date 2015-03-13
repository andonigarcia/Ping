# Ping Collaborative To-Do List

Updated - 13 March 2015 - Andoni Garcia

## Web App

1. Company Page:
  * Analytics and Payments tabs
  * Forms.js is acting funny -- See line 13
  * When Submitting a Ping, try to refresh to ping tab
  * Make responsive
  * Update/refine Pings models
2. Errors:
  * Google Maps:
    Not found addresses/problems with Geocode are not handled
3. CSS:
  * Forms:
  	- **Bug**: Click between help fields leads to build up of <br /> tags
    - **Bug**: First click/offclick on a help field doesn't <br /> the two notifications
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
7. From live test, check the following:
  * Png and jpg image support.
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