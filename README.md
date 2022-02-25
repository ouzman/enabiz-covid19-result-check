# enabiz-covid19-result-check
A simple script to check test results and post them when they are changed as a Slack message

## Requirements
[curl](https://github.com/curl/curl), [pup](https://github.com/ericchiang/pup) and [jq](https://github.com/stedolan/jq)

## Preparation
1. Create [a Slack bot](https://stackoverflow.com/a/63996635)
2. Get cookies from [E-Nabiz](https://enabiz.gov.tr)
    1. Login to the system
    2. Open the developer console of the browser
    3. Naviate to [Tests](https://enabiz.gov.tr/HastaBilgileri/Tahliller)
    4. Get the cookies of the [Tests](https://enabiz.gov.tr/HastaBilgileri/Tahliller) page request

## Usage (MacOS)
Crontab can be useful to check results regularly.
1. Create an environment file, named `.env`
    ```
    export SLACK_TOKEN="xoxb-123-456-abc..."
    export COOKIE="f5_cspm=..."
    export MENTION_USERNAME="username"
    ```
2. Edit the current crontab
    ```console
    $ crontab -e
    ```
3. Add the check script to run for every 2 minutes
    ```
    */2 * * * * cd /tmp/covid19-test-result-check && (source .env && ./check.sh >> ./check.log 2>&1)
    ```