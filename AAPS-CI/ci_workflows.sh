#!/bin/bash

# Set current dit to the location of this script
cd "$(dirname "$(readlink -f "$0")")"

# Set configuration
source ./config.sh

echo -e "Getting active workflows for repo $OWNER/$REPO:\n"

res=$(curl -H "Accept: application/vnd.github.v3+json" \
     -H "Authorization: Bearer $PERSONAL_ACCESS_TOKEN" \
     https://api.github.com/repos/${OWNER}/${REPO}/actions/workflows)

#echo $res | jq
echo $res | jq '.workflows[] | {id, name, url}'
