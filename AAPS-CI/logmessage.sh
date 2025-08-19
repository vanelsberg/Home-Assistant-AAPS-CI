#!/bin/bash

function logmessage {
  message=$1
  echo "$(date) [AAPS CI] ${message}"
  echo "$(date) [AAPS CI] ${message}" >> AAPS_CI.log
}

