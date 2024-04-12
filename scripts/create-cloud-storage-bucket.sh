#!/bin/bash
source send-message.sh

createCloudStorageBucket() {
    local repoName=$1
    local replyTopic=$2
    local bucketName="gs://${repoName}_tf_state"
    local lockFile="terraform.tflock"

    if ! gsutil ls -b "$bucketName" &>/dev/null; then
        echo "Bucket $bucketName does not exist - creating bucket."
        if gsutil mb -b on "$bucketName"; then
            echo "Bucket '$bucketName' created successfully."
            echo "Creating lock file object: $lockFile."
            if (echo -n "This is a lock file for Terraform state locking" | gsutil cp - "$bucketName"/tflock/"$lockFile"); then
                echo "Lock file object created successfully."
            else
                echo "Failed to create lock file object."
                sendMessage "$replyTopic" "Pipeline failed."
                exit 1
            fi
        else
            echo "Failed to create bucket '$bucketName'."
            sendMessage "$replyTopic" "Pipeline failed."
            exit 1
        fi
    else
        echo "Bucket $bucketName already exists."
    fi
}
