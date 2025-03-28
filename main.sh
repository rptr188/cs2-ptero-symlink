#!/bin/bash

# CS2 App ID on SteamCMD
APP_ID=730
# Open your nest and find your EGG ID - for every panel it's different
EGG_ID=15
# Define your base mount folder
BASE_FOLDER=/home/cs2/mount/

# Path to version file - change to yours on host machine
VERSION_FILE="/home/cs2/version.txt"

# Function to fetch current build ID for public branch
get_build_id() {
    # Execute SteamCMD and filter the output for the public branch build ID
    steamcmd +login anonymous +app_info_update 1 +app_info_print "$APP_ID" +quit | tr '\n' ' ' | grep --color=NEVER -Po '"branches"\s*{\s*"public"\s*{\s*"buildid"\s*"\K(\d*)')
}

# Fetch current build ID
CURRENT_BUILD_ID=$(get_build_id)

# Check if we successfully retrieved the build ID
if [ -z "$CURRENT_BUILD_ID" ]; then
    echo "Failed to fetch the build ID. Please check your SteamCMD configuration."
    exit 1
fi

# Check if version.txt exists
if [ ! -f "$VERSION_FILE" ]; then
    echo "$CURRENT_BUILD_ID" > "$VERSION_FILE"
    echo "Version file created with build ID: $CURRENT_BUILD_ID"
    exit 0
fi

# Read the saved build ID from version.txt
SAVED_BUILD_ID=$(cat "$VERSION_FILE")

# Compare build IDs
if [ "$CURRENT_BUILD_ID" != "$SAVED_BUILD_ID" ]; then
    echo "Build ID has changed. Updating servers..."
    
# Here we need to stop all servers with EGG ID defined at the top

# Perform the curl request and store the response in a variable
json_response=$(curl -s "https://panel.url/api/application/servers/$EGG_ID" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer apikey" \
  -X GET")
  
# Use jq to extract identifiers where "egg" equals EGG_ID - ovo nije dobro jos
identifiers=$(echo "$json_response" | jq -r '.data[] | select(.attributes.egg == $EGG_ID) | .attributes.identifier')

# Check if identifiers were found
if [ -z "$identifiers" ]; then
    echo "No identifiers with egg value of $EGG_ID found."
    exit 0
fi

# Function which takes all identifiers and sends stop signal to servers with these IDs, matching EGG ID on the top of the file
for identifier in $identifiers; do
    echo "Sending POST request for identifier: $identifier"
    
    curl -s "https://panel.tld/api/client/servers/$identifier/power" \
      -H "Accept: application/json" \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer apikey" \
      -X POST \
      -d '{
      "signal": "stop"
    }'
    echo "Turned off server with ID $identifier."
done

## OVAJ BLOK SE ODNOSI ISKLJUCIVO NA UPDATE BAZNOG SERVERA

    # Update servers
    steamcmd +login anonymous +force_install_dir $BASE_FOLDER +app_update $APP_ID validate +quit
    
    # Update version.txt with the new build ID
    echo "$CURRENT_BUILD_ID" > "$VERSION_FILE"
    echo "Version file updated with new build ID: $CURRENT_BUILD_ID"
else
    echo "Build ID has not changed. No updates necessary."
fi


