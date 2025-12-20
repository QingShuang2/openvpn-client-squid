#!/bin/sh
URL="${HEALTHCHECK_URL:-http://localhost:3128}"
curl -f "$URL" || exit 1
