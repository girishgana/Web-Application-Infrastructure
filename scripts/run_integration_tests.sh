#!/usr/bin/env bash
set -euo pipefail

STAGING_URL="$1"  # pass e.g. http://my-staging-alb.amazonaws.com
echo "Testing staging URL: $STAGING_URL"
http_status=$(curl -s -o /dev/null -w "%{http_code}" "$STAGING_URL/")
if [ "$http_status" -ne 200 ]; then
  echo "Integration test failed. HTTP status: $http_status"
  exit 1
fi
echo "Integration test passed."
