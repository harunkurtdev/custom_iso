FROM nginx:alpine

# Install curl for health checks
RUN apk add --no-cache curl

# Create app directory
WORKDIR /app

# Copy nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Copy server script
COPY server.sh /app/server.sh
RUN chmod +x /app/server.sh

# Create directories for configurations
RUN mkdir -p /app/configs /var/www/html

# Expose port 80
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost/health || exit 1

# Start the server
CMD ["/app/server.sh"]