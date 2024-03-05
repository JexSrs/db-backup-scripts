#!/bin/sh

# MONGO_DATABASE=
# DATABASE_URL=
# S3_HOST=
# S3_BUCKET=
# S3_ACCESS_KEY=
# S3_SECRET_KEY=

DATE=`date +%F-%H%M`

BACKUP_NAME="$MONGO_DATABASE-$DATE"
BACKUP_DIR="/tmp/$MONGO_DATABASE"

echo "Performing backup of $MONGO_DATABASE"
echo "--------------------------------------------"

# Create backup directory
if ! mkdir -p "$BACKUP_DIR"; then
  echo "Can't create backup directory in $BACKUP_DIR. Quiting!" 1>&2
  exit 1;
fi;

# Request data
mongodump --uri="$DATABASE_URL"
if [ $? -ne 0 ]; then
  echo "Mongodump failed. Exiting!" 1>&2
  exit 1;
fi

# Rename dump directory to backup name
mv dump "$BACKUP_NAME"
# Compress backup
tar -zcvf "$BACKUP_DIR"/"$BACKUP_NAME".tgz "$BACKUP_NAME"

echo "Uploading tgz file to S3..."
echo "--------------------------------------------"

cd "$BACKUP_DIR" || exit
s3cmd put *.tgz s3://"$S3_BUCKET"/mongodb/ --access_key="$S3_ACCESS_KEY" --secret_key="$S3_SECRET_KEY" --host="$S3_HOST"

if [ $? -ne 0 ]; then
  echo "s3cmd failed. Exiting!" 1>&2
  exit 1;
fi

echo "Upload complete!"
echo "--------------------------------------------"

# Clean up
rm -rf "$BACKUP_DIR"