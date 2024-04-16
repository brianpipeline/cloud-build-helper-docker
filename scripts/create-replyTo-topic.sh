#!/bin/bash
source send-message.sh
createReplyToTopic() {
    projectId="$1"
    topicName="$2"
    replyTopic="$3"

    if ! gcloud pubsub topics create "$topicName"; then
        echo "Failed to create topic $topicName"
        sendMessage "$replyTopic" "Pipeline failed."
        exit 1
    fi
    echo "projects/${projectId}/topics/${topicName}"
}
