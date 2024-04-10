#!/bin/bash

source send-message.sh

runCloudBuildTests() {
    local replyTopic=$1
    chmod +x ./tests/submissions.sh
    if ./tests/submissions.sh; then
        echo "Tests passed successfully."
        exit 0
    else
        echo "Tests failed."
        sendMessage "$replyTopic" "Pipeline failed."
        exit 1
    fi
}
