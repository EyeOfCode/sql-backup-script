FROM node:22-alpine

WORKDIR /app

RUN apk update && \
    apk add --no-cache \
    mysql-client \
    bash \
    curl \
    jq \
    git \
    dos2unix \
    dcron && \
    echo "Basic dependencies and dcron installed successfully."

COPY package*.json /app/
RUN npm install

COPY . /app/

RUN chmod +x /app/script.sh && chmod -R 755 /app

RUN touch /var/log/cron.log && chmod 0644 /var/log/cron.log
RUN echo "25 17 * * * /bin/bash /app/script.sh >> /var/log/cron.log 2>&1" > /etc/crontabs/root

CMD ["sh", "-c", "crond -f -l 2 & tail -f /var/log/cron.log"]
