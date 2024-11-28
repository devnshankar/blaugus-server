# Use Node.js image as base
FROM node:alpine

# Install necessary tools: curl, bash, nginx
RUN apk add --no-cache curl bash nginx

# Install Bun
RUN curl -fsSL https://bun.sh/install | bash

# Add Bun binaries to PATH
ENV PATH="/root/.bun/bin:$PATH"

# Set working directory
WORKDIR /app

# Install PM2 globally using Bun
RUN bun install -g pm2

# Copy project files
COPY . .

# Install dependencies for the project
RUN bun install

# Copy the Nginx configuration with placeholder
COPY nginx.conf /etc/nginx/nginx.conf

# Copy the startup script into the container
COPY entrypoint.sh /entrypoint.sh

# Make the startup script executable
RUN chmod +x /entrypoint.sh

# Expose port 80 for external access
EXPOSE 80

# Set the entrypoint to the startup script
ENTRYPOINT ["/entrypoint.sh"]
