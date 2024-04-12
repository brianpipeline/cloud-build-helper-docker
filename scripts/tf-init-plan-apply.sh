#!/bin/bash

source send-message.sh

runTfInitPlanApply() {
    local repoName=$1
    local replyTopic=$2

    if ! terraform init \
        -backend-config="bucket=gs://${repoName}_tf_state" \
        -backend-config="prefix=terraform/state" \
        -backend-config="lock=true" \
        -backend-config="lock_file=terraform.tflock"; then
        echo "Terraform init failed."
        sendMessage "$replyTopic" "Pipeline failed."
        exit 1
    fi
    echo "Terraform init succeeded."
}
