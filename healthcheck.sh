#!/bin/sh

# Mark container unhealthy if no OpenVPN config is present
if ! ls /etc/openvpn/*.conf >/dev/null 2>&1; then
  echo "No OpenVPN config (*.conf) found in /etc/openvpn" >&2
  exit 1
fi

URL="${HEALTHCHECK_URL:-http://localhost:3128}"
curl -f "$URL" || exit 1
