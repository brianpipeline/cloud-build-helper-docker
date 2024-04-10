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
    pipelineFailed=false

    # Loop until message arrives or timeout
    while true; do
        current_time=$(date +%s)
        elapsed_time=$((current_time - start_time))

        message=$(pull_message "$subscription_name")
        if [[ -n $message ]]; then
            echo "Received message: $message"
            if [[ $message == "Pipeline failed." ]]; then
                pipelineFailed=true
            fi
            break
        elif ((elapsed_time >= timeout_duration)); then
            echo "Timeout reached. No message received within allotted time."
            pipelineFailed=true
            break
        else
            sleep 10
        fi
    done

    gcloud pubsub subscriptions delete "$subscription_name" --quiet
    gcloud pubsub topics delete "$replyTopic" --quiet
    if $pipelineFailed; then
        exit 1
    fi
}
