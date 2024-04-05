#!/usr/bin/env bats

load $(pwd)/scripts/await-reply.sh
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

@test "pull_message should successfully pull a message" {
    # Stub gcloud builds submit command to return success
    stub gcloud "echo hello"
    # Run your function
    run pull_message "subscription"
    # Check if it succeeds
    [ "$status" -eq 0 ]
    [[ "$output" == *"Received Message: hello"* ]]
}

@test "pull_message should return 1 when it cannot pull a message" {
    # Stub gcloud builds submit command to return failure
    stub gcloud "exit 0"
    # Run your function
    run pull_message "subscription"
    # Check if it fails
    [ "$status" -eq 1 ]
}

@test "awaitReply should time out when message is not received." {
    # Stub gcloud builds submit command to return failure
    stub gcloud "exit 0"
    # Run your function
    run awaitReply "topic" "subscription" "20"
    # Check if it fails
    [ "$status" -eq 1 ]
    [[ "$output" == *"Timeout reached. No message received within allotted time."* ]]
}

@test "awaitReply should complete with exit code 0 when message is received." {
    # Stub gcloud builds submit command to return failure
    stub gcloud "echo hello"
    # Run your function
    run awaitReply "topic" "subscription" "20"
    # Check if it fails
    [ "$status" -eq 0 ]
    [[ "$output" == *"Received Message: hello"* ]]
}
