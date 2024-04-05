#!/usr/bin/env bats

load $(pwd)/scripts/create-replyTo-topic.sh
BATS_TEST_DIRNAME=$(pwd)
export PATH="$BATS_TEST_DIRNAME/stub:$PATH"

stub() {
    if [ ! -d $BATS_TEST_DIRNAME/stub ]; then
        mkdir $BATS_TEST_DIRNAME/stub
    fi
    echo $2 >$BATS_TEST_DIRNAME/stub/$1
    chmod +x $BATS_TEST_DIRNAME/stub/$1
}

rm_stubs() {
    rm -rf $BATS_TEST_DIRNAME/stub
}

teardown() {
    rm_stubs
}

@test "createReplyToTopic should successfully create topic" {
    # Stub gcloud builds submit command to return success
    stub gcloud "exit 0"
    # Run your function
    run createReplyToTopic "test-project" "test-topic"
    # Check if it succeeds
    [ "$status" -eq 0 ]
    [[ "$output" == *"projects/test-project/topics/test-topic"* ]]
}

@test "deployPipelines should handle failed topic creation" {
    # Stub gcloud builds submit command to return failure
    stub gcloud "exit 1"
    # Run your function
    run createReplyToTopic "test-project" "test-topic"
    echo $output
    # Check if it fails
    [ "$status" -eq 1 ]
    [[ "$output" == *"Failed to create topic test-topic"* ]]
}
