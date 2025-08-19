#!/bin/bash

# Set current dit to the location of this script
cd "$(dirname "$(readlink -f "$0")")"

# Set configuration
source ./config.sh

echo "Syncing fork $OWNER/$REPO with upstream:"

# Request syncing fork
response=$(curl -X POST \
  -H "Authorization: token $PERSONAL_ACCESS_TOKEN" \
  -H "Accept: application/vnd.github+json" \
  https://api.github.com/repos/${OWNER}/${REPO}/merge-upstream \
  -d "{\"branch\":\"$BRANCH\"}")

# Validate response: Expected values
expected_merge_type="fast-forward"
expected_base_branch="nightscout:dev"

# Extract values using jq
merge_type=$(echo "$response" | jq -r '.merge_type')
base_branch=$(echo "$response" | jq -r '.base_branch')
message=$(echo "$response" | jq -r '.message')

# echo "merge_type: $merge_type"
# echo "base_branch: $base_branch"

# Verify the values
if [[ "$merge_type" == "$expected_merge_type" && "$base_branch" == "$expected_base_branch" ]]; then
  echo "✅ $message"
  exit 1 # Sync was succesfull.
else
  echo "❌ $message"
  exit 0 # No Sync was done.
fi

