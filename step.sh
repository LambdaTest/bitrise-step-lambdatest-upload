#!/bin/bash
set -e
set -x
set -o pipefail

UPLOAD_PATH=${upload_path}
APP_NAME=${app_name}
APP_VISIBILITY=${app_visibility}
CUSTOM_ID=${custom_id}

# Validate UPLOAD_PATH
if [ -z "${UPLOAD_PATH}" ]; then
    echo "ERROR: upload_path is required but not provided"
    exit 1
fi

# Check if UPLOAD_PATH is a URL or local file
if [ -z "${UPLOAD_PATH##*http*}" ]; then
    if [ "${show_debug_logs}" == "true" ]; then
        echo "Uploading from URL: ${UPLOAD_PATH}"
    fi
    
    # Upload from URL
    HTTP_STATUS=$(curl --location --request POST "https://$lambdatest_username:$lambdatest_access_key@manual-api.lambdatest.com/app/upload/realDevice" \
    --header "Content-Type: application/json" \
    --data-raw '{"url":"'$UPLOAD_PATH'","custom_id":"'$custom_id'","name":"'$APP_NAME'","visibility":"'$APP_VISIBILITY'"}' \
    -o ".upload-app-response.json" \
    -w "%{http_code}")
    
    if [ "$HTTP_STATUS" -ne 200 ]; then
        echo "ERROR: Upload failed with HTTP status: $HTTP_STATUS"
        if [ -f ".upload-app-response.json" ]; then
            echo "Response content:"
            cat ".upload-app-response.json"
        fi
        exit 1
    fi
else
    # Check if local file exists
    if [ ! -f "${UPLOAD_PATH}" ]; then
        echo "ERROR: Local file '${UPLOAD_PATH}' does not exist"
        exit 1
    fi
    
    if [ "${show_debug_logs}" == "true" ]; then
        echo "Uploading local file: ${UPLOAD_PATH}"
    fi
    
    # Upload local file
    HTTP_STATUS=$(curl --location --request POST "https://$lambdatest_username:$lambdatest_access_key@manual-api.lambdatest.com/app/upload/realDevice" \
    --form "name=$APP_NAME" \
    --form "custom_id=$CUSTOM_ID" \
    --form "appFile=@"$UPLOAD_PATH"" \
    --form "visibility=$APP_VISIBILITY" \
    -o ".upload-app-response.json" \
    -w "%{http_code}")
    
    if [ "$HTTP_STATUS" -ne 200 ]; then
        echo "ERROR: Upload failed with HTTP status: $HTTP_STATUS"
        if [ -f ".upload-app-response.json" ]; then
            echo "Response content:"
            cat ".upload-app-response.json"
        fi
        exit 1
    fi
fi

# Check if response file exists and contains valid JSON
if [ ! -f ".upload-app-response.json" ]; then
    echo "ERROR: Response file not found"
    exit 1
fi

# Parse response and extract app_url
APP_URL=$(cat ".upload-app-response.json" | jq -r '.app_url')

if [ "$APP_URL" == "null" ] || [ -z "$APP_URL" ]; then
    echo "ERROR: Failed to extract app_url from response"
    echo "Response content:"
    cat ".upload-app-response.json"
    exit 1
fi

echo "Upload successful! App URL: ${APP_URL}"
envman add --key LAMBDATEST_APP_URL --value ${APP_URL}

# Clean up temporary file
rm -f ".upload-app-response.json"