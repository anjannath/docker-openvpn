#!/usr/bin/env bash

podman run --cap-add=NET_ADMIN \
-p 8800:8080/tcp \
-e HOST_ADDR=localhost \
--rm \
docker.io/anjan/obfsvpn-openvpn "$@"
