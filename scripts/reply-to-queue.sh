#!/bin/bash

reply() {
    local replyTopic=$1
    local replyMessage=$2

    gcloud pubsub topics publish "$replyTopic" --message="$replyMessage"
}
