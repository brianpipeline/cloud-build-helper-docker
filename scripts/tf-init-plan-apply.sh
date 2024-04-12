#!/bin/bash

source send-message.sh

runTfInitPlanApply() {
    local repoName=$1
    local gitRef=$2
    local replyTopic=$3

    if ! terraform init \
        -backend-config="bucket=gs://${repoName}_tf_state/" \
        -backend-config="prefix=terraform/state"; then
        echo "Terraform init failed."
        sendMessage "$replyTopic" "Pipeline failed."
        exit 1
    fi
    echo "Terraform init succeeded."

    if ! terraform plan -out=tfplan; then
        echo "Terraform plan failed."
        sendMessage "$replyTopic" "Pipeline failed."
        exit 1
    fi
    echo "Terraform init succeeded"

    if [[ $gitRef == "refs/heads/main" ]]; then
        if ! terraform apply tfplan; then
            echo "Terraform apply failed."
            sendMessage "$replyTopic" "Pipeline failed."
            exit 1
        fi
        echo "Terraform apply succeeded."
    else
        echo "Not on main branch, skipping Terraform apply."
    fi
}
