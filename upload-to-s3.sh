#!/bin/bash

# Environment variables: FILE_PATH, BACKUP_FILE, AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_DEFAULT_REGION, BUCKET_URI

echo "Uploading backup file to S3 ..."

aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID
aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY
aws configure set default.region $AWS_DEFAULT_REGION
aws s3 cp "$FILE_PATH/$BACKUP_FILE" "s3://$BUCKET_URI/$BACKUP_FILE"

echo "Successfully backup database to S3"