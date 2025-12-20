# Tunnelizer

Tunnelizer is a minimal Docker image that runs a Squid HTTP proxy over an OpenVPN tunnel. It is designed for scenarios where you want to proxy HTTP(S) traffic through a VPN, and supports advanced proxy chaining inside the VPN network. The image features:

- Squid configured to forward **all traffic to a specific upstream IP:port** passed via environment variables
- A customizable health check endpoint
- Utility scripts for easy building and tagging

## Features

- Squid HTTP proxy server
- OpenVPN client for secure tunneling
- **Dynamic Squid config** based on `UPSTREAM_IP` and `UPSTREAM_PORT`
- Customizable health check endpoint (via `HEALTHCHECK_URL` environment variable)
- Lightweight Alpine Linux base
- Utility scripts for building and tagging the image

## Getting Started

### 1. Build the Docker Image

You can build the image with a custom name using the provided script:

```sh
chmod +x build-image.sh
./build-image.sh tunnelizer:latest .
```

If you run the script without arguments, it defaults to building and tagging as `proxier`:

```sh
./build-image.sh
```

### 2. Prepare OpenVPN Configuration

Mount your OpenVPN `.conf` file(s) into `/etc/openvpn` in the container. Only one config file should be present for correct operation.

### 3. Environment Variables for Squid Upstream

Squid no longer uses its default configuration. On container start, the `entrypoint.sh` script **generates `/etc/squid/squid.conf` dynamically** using these environment variables:

- `UPSTREAM_IP` (required): The IP address of the upstream proxy/host inside the VPN.
- `UPSTREAM_PORT` (required): The port of the upstream proxy/host.

All HTTP traffic accepted by Squid on port `3128` will be forwarded to `UPSTREAM_IP:UPSTREAM_PORT`.

If either `UPSTREAM_IP` or `UPSTREAM_PORT` is missing, the container will exit with an error.

### 4. Run the Container

Basic example:

```sh
docker run --rm \
  -v /path/to/your/openvpn.conf:/etc/openvpn/your.conf \
  -e UPSTREAM_IP="10.0.0.5" \
  -e UPSTREAM_PORT="8080" \
  tunnelizer:latest
```

With a custom health check endpoint (for example, a proxy or service reachable through the VPN):

```sh
docker run --rm \
  -v /path/to/your/openvpn.conf:/etc/openvpn/your.conf \
  -e UPSTREAM_IP="10.0.0.5" \
  -e UPSTREAM_PORT="8080" \
  -e HEALTHCHECK_URL="http://10.0.0.5:8080" \
  tunnelizer:latest
```

### 5. Health Check

The container includes a health check that uses `healthcheck.sh` + `curl` to verify the specified endpoint is reachable from inside the container.

- `HEALTHCHECK_URL` (optional): Set this to customize the health check endpoint. Defaults to `http://localhost:3128` (the local Squid proxy).

This helps ensure the proxy (or the upstream service you care about) is up and accessible.

## Included Scripts

- **entrypoint.sh**
  - Validates `UPSTREAM_IP` and `UPSTREAM_PORT`.
  - Generates a minimal `squid.conf` with:
    - `http_port 3128`
    - `cache_peer ${UPSTREAM_IP} parent ${UPSTREAM_PORT} 0 no-query default`
    - `never_direct allow all` (force all traffic through the upstream)
    - `http_access allow all`
    - `cache deny all` (no caching)
  - Starts OpenVPN and then Squid in the foreground.

- **healthcheck.sh**
  - Used internally for the Docker health check; reads `HEALTHCHECK_URL` to determine which endpoint to check.

- **build-image.sh**
  - Build the Docker image with a custom or default name.
  - Defaults to `proxier` and current directory if you provide no arguments.

## Example Usage

Build and run with defaults (image name only):

```sh
./build-image.sh
# image name: proxier

docker run --rm \
  -v /path/to/your/openvpn.conf:/etc/openvpn/your.conf \
  -e UPSTREAM_IP="10.0.0.5" \
  -e UPSTREAM_PORT="8080" \
  proxier
```

Build and run with custom name and health check:

```sh
./build-image.sh tunnelizer:latest .

docker run --rm \
  -v /path/to/your/openvpn.conf:/etc/openvpn/your.conf \
  -e UPSTREAM_IP="10.0.0.5" \
  -e UPSTREAM_PORT="8080" \
  -e HEALTHCHECK_URL="http://10.0.0.5:8080" \
  tunnelizer:latest
```

## Notes

- Ensure only one OpenVPN config file is present in `/etc/openvpn` for correct operation.
- The container runs both OpenVPN and Squid. If OpenVPN fails to start, Squid may still run, so monitor logs and health status.
- For advanced proxy chaining, point `UPSTREAM_IP:UPSTREAM_PORT` to another proxy inside the VPN and set `HEALTHCHECK_URL` accordingly.

## License

MIT License
