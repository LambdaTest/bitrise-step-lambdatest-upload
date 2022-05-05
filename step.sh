#!/bin/bash
set -e
set -x
set -o pipefail

UPLOAD_PATH=${upload_path}
APP_NAME=${app_name}
CUSTOM_ID=${custom_id}
BASICAUTH=$(echo -n $lambdatest_username:$lambdatest_access_key | base64)

if [ -z "${UPLOAD_PATH##*http*}" ]; then
    curl -u "$lambdatest_username:$lambdatest_access_key" --location --request POST https://manual-api.lambdatest.com/app/upload/realDevice \
    --header 'Content-Type: application/json' \
    --data-raw '{"url":"'$UPLOAD_PATH'","custom_id":"'$custom_id'", "name":"'$APP_NAME'"}' \
    -o ".upload-app-response.json"
else
    curl --location --request POST 'https://manual-api.lambdatest.com/app/upload/realDevice' \
    --header "Authorization: Basic $BASICAUTH" \
    --form "name=$APP_NAME" \
    --form "custom_id=$CUSTOM_ID" \
    --form "appFile=@"$UPLOAD_PATH"" \
    -o ".upload-app-response.json"
fi

APP_URL=$(cat ".upload-app-response.json" | jq -j '.app_url')
envman add --key LAMBDATEST_APP_URL --value ${APP_URL}