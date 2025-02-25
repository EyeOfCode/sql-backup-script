FROM ubuntu:20.04

# Install necessary packages
RUN apt-get update && \
    apt-get install -y \
    curl \
    bash \
    mysql-client \
    cron \
    gnupg2 \
    lsb-release \
    ca-certificates && \
    # Install Node.js (which includes npm)
    curl -sL https://deb.nodesource.com/setup_16.x | bash - && \
    apt-get install -y nodejs && \
    # Install firebase-tools globally
    npm install -g firebase-tools && \
    # Clean up apt lists and npm cache to reduce image size
    rm -rf /var/lib/apt/lists/* && \
    npm cache clean --force

# Set working directory
WORKDIR /app

# Copy the backup script and .env to the container
COPY . /app
COPY .env /app/.env

# Make the backup script executable
RUN chown -R root:root /app
RUN chmod 755 /app/script.sh
RUN chmod 644 /app/.env

# Set up cron job to run backup and log output to stdout/stderr
RUN echo "* * * * * /bin/bash /app/script.sh >> /dev/stdout 2>> /dev/stderr" > /etc/cron.d/backup-job
RUN chmod 0644 /etc/cron.d/backup-job
RUN chown root:root /etc/cron.d/backup-job
RUN crontab /etc/cron.d/backup-job

# Start cron in the foreground
CMD ["cron", "-f"]
