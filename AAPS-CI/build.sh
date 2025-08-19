#!/bin/bash

# Change current dir to  AAPS CI script location
cd "$(dirname "$(readlink -f "$0")")"

# Import logging
source ./logmessage.sh
# Set configuration
source ./config.sh

#################################################################
# Start integration task
#################################################################

logmessage "Build requested" 

# Run script to detect chnages: fork needs updates?
./sync_with_upstream.sh

# Check scripts exit code
if [ $? -eq 1 ]; then
  logmessage "✅ Local branch was synced:"
  logmessage "Preparing to run AAPS CI!"
else
  logmessage "❌ Local branch is up to date....."
  #  if [ "$1" = "--force" ]; then
  #    echo "Forced run of AAPS CI requested....."
  #    echo "$(date) [AAPS CI] Forced run requested....." >> build.log
  #  else
  #    exit 0
  #  fi
fi

# logmessage "https://api.github.com/repos/${OWNER}/${REPO}/dispatches" # DEBUG
# logmessage "$PERSONAL_ACCESS_TOKEN"					# DEBUG

logmessage "Starting workflow AAPS CI for build variant ${OPT_BUILDVARIANT}"

# Start workflow AAPS CI
curl -X POST \
  -H "Accept: application/vnd.github.v3+json" \
  -H "Authorization: Bearer $PERSONAL_ACCESS_TOKEN" \
  https://api.github.com/repos/${OWNER}/${REPO}/actions/workflows/$WORKFLOW_ID/dispatches \
  -d "{
    \"ref\": \"${BRANCH}\",
    \"inputs\": {
        \"buildVariant\": \"${OPT_BUILDVARIANT}\"
    }
  }"

logmessage "Check GitHub or your Google drive for results..."

