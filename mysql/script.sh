#!/bin/sh

# MYSQL_DATABASE=
# MYSQL_USER=
# MYSQL_PASSWORD=
# MYSQL_HOST=
# S3_BUCKET=
# S3_ACCESS_KEY=
# S3_SECRET_KEY=
# S3_HOST=

DATE=$(date +%F-%H%M)

BACKUP_NAME="$MYSQL_DATABASE-$DATE"
BACKUP_DIR="/tmp/$MYSQL_DATABASE"

echo "Performing backup of $MYSQL_DATABASE"
echo "--------------------------------------------"

# Create backup directory
if ! mkdir -p "$BACKUP_DIR"; then
  echo "Can't create backup directory in $BACKUP_DIR. Quitting!" 1>&2
  exit 1;
fi;

# Export database
mysqldump -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" -h "$MYSQL_HOST" "$MYSQL_DATABASE" > "$BACKUP_DIR"/"$BACKUP_NAME".sql
if [ $? -ne 0 ]; then
  echo "mysqldump failed. Exiting!" 1>&2
  exit 1;
fi

# Compress backup
tar -zcvf "$BACKUP_DIR"/"$BACKUP_NAME".tgz "$BACKUP_DIR"/"$BACKUP_NAME".sql

echo "Uploading tgz file to S3..."
echo "--------------------------------------------"

cd "$BACKUP_DIR" || exit
s3cmd put "$BACKUP_NAME".tgz s3://"$S3_BUCKET"/mysql/ --access_key="$S3_ACCESS_KEY" --secret_key="$S3_SECRET_KEY" --host="$S3_HOST"

if [ $? -ne 0 ]; then
  echo "s3cmd failed. Exiting!" 1>&2
  exit 1;
fi

echo "Upload complete!"
echo "--------------------------------------------"

# Clean up
rm -rf "$BACKUP_DIR"
