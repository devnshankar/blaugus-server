#!/bin/bash

set -e

# Function to print error messages and exit
error_exit() {
  echo "Error: $1" >&2
  exit 1
}

# Set default values if environment variables are not set
SERVER_PORT=${SERVER_PORT:-3050}
CLIENT_URL=${CLIENT_URL:-http://localhost:5173/}

echo "Starting the backend server with SERVER_PORT=${SERVER_PORT} and CLIENT_URL=${CLIENT_URL}"

# Export environment variables for the server
export SERVER_PORT
export CLIENT_URL

# Ensure the blogs directory exists
BLOGS_DIR="/app/blogs"
if [ ! -d "${BLOGS_DIR}" ]; then
  echo "Blogs directory does not exist. Creating..."
  mkdir -p "${BLOGS_DIR}" || error_exit "Failed to create blogs directory."
fi

# Replace the placeholder in nginx.conf with the actual SERVER_PORT
NGINX_CONF="/etc/nginx/nginx.conf"
PLACEHOLDER="__SERVER_PORT__"

if [ -f "$NGINX_CONF" ]; then
  echo "Configuring NGINX to proxy to backend on port ${SERVER_PORT}..."
  sed -i "s/__SERVER_PORT__/${SERVER_PORT}/g" "$NGINX_CONF" || error_exit "Failed to configure NGINX."
else
  error_exit "Nginx configuration file not found at $NGINX_CONF"
fi

# Start the backend server using PM2
echo "Starting backend server with PM2..."
pm2 start index.ts --name blaugus-server --interpreter bun || error_exit "Failed to start backend server with PM2."

# Verify that the backend server started successfully
if ! pm2 describe blaugus-server > /dev/null 2>&1; then
  error_exit "PM2 failed to start the backend server."
fi

echo "Backend server started successfully."

# Start NGINX in the foreground
echo "Starting NGINX..."
nginx -g 'daemon off;' || error_exit "Failed to start NGINX."
