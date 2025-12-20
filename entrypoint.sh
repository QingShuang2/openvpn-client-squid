#!/bin/bash
set -e

# Expect UPSTREAM_IP and UPSTREAM_PORT to be provided as environment variables.
if [ -z "$UPSTREAM_IP" ] || [ -z "$UPSTREAM_PORT" ]; then
  echo "ERROR: UPSTREAM_IP and UPSTREAM_PORT must be set (e.g. -e UPSTREAM_IP=10.0.0.5 -e UPSTREAM_PORT=8080)" >&2
  exit 1
fi

# Generate a minimal Squid config that forwards all traffic to the specified upstream.
cat > /etc/squid/squid.conf <<EOF
http_port 3128
acl all src 0.0.0.0/0
cache_peer ${UPSTREAM_IP} parent ${UPSTREAM_PORT} 0 no-query default
never_direct allow all
http_access allow all
cache deny all
EOF

# Start OpenVPN and Squid
cd /etc/openvpn
/usr/sbin/openvpn --config *.conf &

rm -rf /var/run/squid.pid
exec squid -N
