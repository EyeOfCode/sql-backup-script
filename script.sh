#!/bin/bash

# Load environment variables from .env file
export $(cat .env | grep -v '^#' | xargs)

echo "Checking if the backup directory exists..."
if [ ! -d "$BACKUP_PATH" ]; then
  echo "Backup directory doesn't exist. Creating it..."
  mkdir -p $BACKUP_PATH
else
  echo "Backup directory exists."
fi

# Step 1: Remove backups older than $KEEP_BACKUP_DAYS
echo "Removing backups older than $KEEP_BACKUP_DAYS days..."
find $BACKUP_PATH -type f -name "*.sql" -mtime +$KEEP_BACKUP_DAYS -exec rm -f {} \;

# Step 2: Backup MySQL database in Docker container
echo "Starting MySQL backup..."
DATE=$(date +"%Y%m%d%H%M%S")
mysqldump -h $DB_HOST -u $DB_USER -p$DB_PASS $DB_NAME > $BACKUP_PATH/backup_${DB_NAME}_$DATE.sql

# Step 3: Delay before uploading (e.g., sleep for 5 minutes)
# echo "Waiting for 5 minutes before uploading backup to Firebase..."
# sleep 300  # 300 seconds = 5 minutes

# Step 4: Upload to Firebase
echo "Uploading backup to Firebase Storage..."

# Authenticate with Firebase
export GOOGLE_APPLICATION_CREDENTIALS=$FIREBASE_CREDENTIALS_PATH
firebase login --no-localhost --token $(firebase login:ci)

# Upload the backup to Firebase Storage
firebase storage:upload $BACKUP_PATH/backup_$(date +\%F).sql --bucket $FIREBASE_BUCKET

# Confirm upload
if [ $? -eq 0 ]; then
  echo "Backup uploaded successfully to Firebase."
else
  echo "Failed to upload the backup."
fi
