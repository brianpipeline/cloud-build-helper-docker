#!/bin/bash
pull_message() {
    subscription_name=$1
    message=$(gcloud pubsub subscriptions pull --auto-ack "$subscription_name" --format='value(message.data)' 2>/dev/null)
    if [[ -n $message ]]; then
        echo "Received Message: $message"
        return 0
    else
        return 1
    fi
}

awaitReply() {
    local replyTopic=$1
    local subscription_name=$2
    local timeout_duration=$3

    gcloud pubsub subscriptions create "$subscription_name" \
        --topic "$replyTopic"

    start_time=$(date +%s)

    # Loop until message arrives or timeout
    while true; do
        current_time=$(date +%s)
        elapsed_time=$((current_time - start_time))

        if pull_message "$subscription_name"; then
            break
        elif ((elapsed_time >= timeout_duration)); then
            echo "Timeout reached. No message received within allotted time."
            exit 1
        else
            sleep 10
        fi
    done
}
