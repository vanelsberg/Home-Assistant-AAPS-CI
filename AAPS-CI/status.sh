#!/bin/bash

# Set current dit to the location of this script
cd "$(dirname "$(readlink -f "$0")")"

# Set configuration
source ./config.sh

echo -e "Workflow status for $OWNER/$REPO, ID=$WORKFLOW_ID:\n"

# Get json response and order by created_at (most recent item las)
#
curl https://api.github.com/repos/${OWNER}/${REPO}/actions/workflows/${WORKFLOW_ID}/runs | \
jq '.workflow_runs | sort_by(.created_at) | map(select(.name == "AAPS CI")) | map({display_title, status, conclusion, run_number, created_at, html_url})'

