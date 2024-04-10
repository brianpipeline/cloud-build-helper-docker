#!/bin/bash
source send-message.sh

runDockerfileTests() {
    replyTopic=$1
    testCommand=$(yq eval '.testCommand' "pipeline.yaml")
    if [[ $testCommand == "null" ]]; then
        echo "No test command found in pipeline.yaml."
        exit 0
    fi

    if ! eval "$testCommand"; then
        sendMessage "$replyTopic" "Pipeline failed."
        echo "Dockerfile tests failed."
        exit 1
    else
        echo "Dockerfile tests passed successfully."
    fi
}
