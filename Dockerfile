# Use a lightweight Alpine Linux base image
FROM python:3.9-alpine

# Set working directory
WORKDIR /app

# Copy necessary files to the container
COPY . /app

# Install dependencies (including dcron for cron jobs)
RUN apk update && \
    apk add --no-cache \
    mysql-client \
    bash \
    curl \
    jq \
    git \
    python3 \
    py3-pip \
    libmagic \
    nodejs \
    npm \
    dos2unix \
    dcron && \
    echo "Basic dependencies and dcron installed successfully."

# Make the script executable
RUN chmod +x /app/backups_db && chmod -R 777 /app/backups_db
RUN chmod +x /app/.env
RUN chmod +x /app/script.sh && dos2unix /app/script.sh

# Add the cron job to run the script every 03:00 AM
RUN touch /var/log/cron.log
RUN chmod 0644 /var/log/cron.log
RUN echo "0 3 * * * /bin/bash /app/script.sh >> /var/log/cron.log 2>&1" > /etc/crontabs/root
RUN crond

# Start dcron (cron daemon) in the background
CMD ["sh", "-c", "crond && tail -f /dev/null"]
