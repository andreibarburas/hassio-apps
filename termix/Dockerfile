# https://developers.home-assistant.io/docs/add-ons/configuration#add-on-dockerfile
FROM ghcr.io/lukegus/termix:latest

# Switch to root user to create directories and setup symlinks
USER root

# Ensure required directories exist with proper permissions
# Create /data with write permissions for all users since we don't know the UID
RUN mkdir -p /app /data && chmod 1777 /data

# Remove the default /app/data directory if it exists
RUN rm -rf /app/data

# Create a symlink from /app/data to /data
# This ensures Termix stores data in Home Assistant's backed-up location
RUN ln -sf /data /app/data

# Set environment variable for port
ENV PORT=8080

# Expose the port
EXPOSE 8080

# The base image should already have the CMD/ENTRYPOINT configured