#!/bin/bash

download_dir="./downloads"

# Extract Access Key ID and Secret Access Key from the output using jq (JSON processor)
AWS_ACCESS_KEY_ID=$(terraform output -raw access_key)
AWS_SECRET_ACCESS_KEY=$(terraform output -raw secret_key)

# List S3 buckets
buckets=$(aws s3 ls | awk '{print $3}')

# Create download directory if it doesn't exist
mkdir -p $download_dir

# Iterate through each bucket
for bucket in $buckets; do
  # Check if the bucket name contains "pgo"
  if [[ "$bucket" == *"pgo"* ]]; then
    # List objects in the bucket, recursively
    objects=$(aws s3 ls s3://"$bucket" --recursive)
        
    # Check if passwords.zip exists in the bucket
    if echo "$objects" | grep -q "passwords.zip"; then
      echo '{"passwords.zip": "'$bucket'"}'

      # Extract the file path
      file_path=$(echo "$objects" | grep "passwords.zip" | awk '{print $NF}')
            
      # Download passwords.zip
      aws s3 cp "s3://$bucket/$file_path" $download_dir/ >/dev/null
      break
    fi
  fi
done
