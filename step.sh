#!/bin/bash
set -e
set -x
set -o pipefail

curl -u "$lambdatest_username:$lambdatest_access_key" --location --request POST https://manual-api.lambdatest.com/app/upload/realDevice --header 'Content-Type: application/json' --data-raw '{"url":"'$upload_path'","custom_id":"'$custom_id'", "name":"'$app_name'"}' -o ".upload-app-response.json" | jq -j '.app_url' 

APP_URL=$(cat ".upload-app-response.json" | ack -o --match '(?<=app_url\":")([_\%\&=\?\.aA-zZ0-9:/-]*)')
envman add --key LAMBDATEST_APP_URL --value ${APP_URL}