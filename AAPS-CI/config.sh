#!/bin/bash

# Note Get workflows, get ID for WORKFLOW_ID setting below:
# curl -H "Accept: application/vnd.github.v3+json" \
#     -H "Authorization: Bearer $PERSONAL_ACCESS_TOKEN" \
#     https://api.github.com/repos/${OWNER}/${REPO}/actions/workflows

OWNER=vanelsberg<Your forked repo owner name>
REPO=<You forked repro name>
WORKFLOW_ID=123456789
PERSONAL_ACCESS_TOKEN=$(cat ../secrets.yaml | grep aaps_ci_access_token_ha | cut -d ':' -f2 | xargs)

# Note on buildvariant:
#  default: "fullRelease"
#  options:
#    - fullRelease
#    - fullDebug
#    - aapsclientRelease
#    - aapsclientDebug
#    - aapsclient2Release
#    - aapsclient2Debug
#    - pumpcontrolRelease
#    - pumpcontrolDebug

OPT_BUILDVARIANT=fullRelease

# AAPS CI Branch to build
BRANCH="dev"
