#!/bin/sh

set -e

echo "Starting shell web app on port 8080"

httpd -f -p 8080 -h /www
