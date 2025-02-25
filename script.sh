#!/bin/bash

# Load environment variables from .env file
if [ "$NODE" == "production" ]; then
  export $(cat /app/.env | grep -v '^#' | xargs)
else
  export $(cat .env | grep -v '^#' | xargs)
fi

if [ "$NODE" == "production" ]; then
  DIR_BACKUP="/app/backups_db"
else
  DIR_BACKUP="/backups_db"
fi

# Step 1: Backup MySQL database in Docker container
echo "Starting MySQL backup..."
set -x
DATE=$(date +"%Y%m%d%H%M%S")
mariadb-dump --ssl=false -h $DB_HOST -u $DB_USER -p$DB_PASS $DB_NAME > "$DIR_BACKUP/backup_${DB_NAME}_$DATE.sql"
set -x
echo "Backup backups_db/backup_${DB_NAME}_$DATE.sql local successfully."

# Step 2: Delay before uploading (e.g., sleep for 5 minutes)
# echo "Waiting for 5 minutes before uploading backup to Firebase..."
# sleep 300  # 300 seconds = 5 minutes

# Step 3: Upload to Firebase
echo "Uploading backup to Firebase Storage..."
if [ "$NODE" == "production" ]; then
  node /app/upload.js
else
  node upload.js
fi

# Confirm upload
if [ $? -eq 0 ]; then
  echo "Backup uploaded successfully to Firebase."
  
  # Step 4: Remove backups older
  echo "Removing backups older..."
  find $DIR_BACKUP -type f -name "*.sql" -exec rm -f {} \;
else
  echo "Failed to upload the backup."
fi
