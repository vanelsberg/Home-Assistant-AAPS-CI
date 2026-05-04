#!/bin/bash

source ./ci.config

echo -e "Getting active workflows for repo $OWNER/$REPO:\n"

res=$(curl -H "Accept: application/vnd.github.v3+json" \
     https://api.github.com/repos/${OWNER}/${REPO}/actions/workflows)

# When you are hitting GitHuv request rating the above may not work whan used multiple times
# To solve, uncomment below to use authenticated requests (and make sure to define WF_PERSONAL_ACCESS_TOKEN):

# res=$(curl -H "Accept: application/vnd.github.v3+json" \
#     -H "Authorization: Bearer $WF_PERSONAL_ACCESS_TOKEN" \
#     https://api.github.com/repos/${OWNER}/${REPO}/actions/workflows)

echo $res | jq '.workflows[] | {id, name, url}'
