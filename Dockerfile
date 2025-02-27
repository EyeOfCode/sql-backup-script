# Use a lightweight Alpine Linux base image
FROM python:3.9-alpine

# Set working directory
WORKDIR /app

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

# Copy package.json and package-lock.json and install npm dependencies
COPY package*.json /app/
RUN npm install

# Copy necessary files to the container
COPY . /app/

# Make the script executable and ensure the correct permissions for all files
RUN chmod -R 777 /app

# Add the cron job to run the script every minute (you can change this to run at 3:00 PM by adjusting the cron pattern)
RUN touch /var/log/cron.log && chmod 0644 /var/log/cron.log
RUN echo "0 15 * * * /bin/bash /app/script.sh >> /var/log/cron.log 2>&1" > /etc/crontabs/root

# Start cron and tail logs
CMD ["sh", "-c", "crond -f -l 2 & tail -f /var/log/cron.log"]
