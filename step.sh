#!/bin/bash
set -e
set -x
set -o pipefail
curl -u "$lambdatest_username:$lambdatest_access_key" --location --request POST https://manual-api.lambdatest.com/app/upload/realDevice --header 'Content-Type: application/json' --data-raw '{"url":"'$upload_path'","name":"sample.apk"}' | jq -j '.app_url' | envman add --key LAMBDATEST_APP_URL