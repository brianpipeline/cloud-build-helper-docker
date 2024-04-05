#!/bin/bash
createReplyToTopic() {
    projectId="$1"
    topicName="$2"

    if ! gcloud pubsub topics create "$topicName"; then
        echo "Failed to create topic $topicName"
        exit 1
    fi
    echo "projects/${projectId}/topics/${topicName}"
}
