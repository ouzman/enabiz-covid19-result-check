#!/bin/bash

set -eu

# SLACK_TOKEN=
# COOKIE=
# MENTION_USERNAME=
OUTPUT_FILE="./output.txt"

function post_to_slack {
  text=$1

  curl -X POST https://slack.com/api/chat.postMessage \
    -H "Authorization: Bearer $SLACK_TOKEN" \
    -H 'Content-type: application/json; charset=utf-8' \
    --data "{\"channel\":\"#covid-test-result\",\"link_names\":true,\"text\":\"$text\"}" \
    --silent    
}

html_response=$(curl 'https://enabiz.gov.tr/HastaBilgileri/Tahliller' \
  -H 'Connection: keep-alive' \
  -H 'Cache-Control: max-age=0' \
  -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/96.0.4664.93 Safari/537.36' \
  -H 'Origin: https://enabiz.gov.tr' \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9' \
  -H 'Referer: https://enabiz.gov.tr/HastaBilgileri/Tahliller' \
  -H 'Accept-Language: en-US,en;q=0.9' \
  -H "Cookie: $COOKIE" \
  --compressed \
  --silent)

table_as_json=$(echo $html_response | pup 'table#Covid19TahlilTable tr[data-tt-id] json{}')

output=$(echo $table_as_json | jq -r '.[] | .children[3].text + " " + .children[2].text')

if [ -z "$output" ]; then
  >&2 echo "output is empty"
  exit 1
fi

if [ -f "$OUTPUT_FILE" ]; then
  old_output=$(cat $OUTPUT_FILE)
  if [ "$old_output" == "$output" ]; then
    post_to_slack "same"
  else
    post_to_slack "it changed! @${MENTION_USERNAME}\n\`\`\`$output\`\`\`"
    echo "$output" > $OUTPUT_FILE  
  fi
else
  echo "$output" > $OUTPUT_FILE
fi
