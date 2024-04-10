#!/usr/bin/env bats

load $(pwd)/send-message.sh
load $(pwd)/run-dockerfile-tests.sh
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

@test "runDockerfileTests should run dockerfile tests and exit 0 on success" {
    # Stub gcloud builds submit command to return success
    stub yq "echo 'echo hello'"
    # Run your function
    run runDockerfileTests "replyTopic"
    # Check if it succeeds
    [ "$status" -eq 0 ]
    [[ "$output" == *"Dockerfile tests passed successfully."* ]]
}

@test "runDockerfileTests should exit 1 if tests fail" {
    # Stub gcloud builds submit command to return success
    stub yq "echo false"
    stub gcloud "exit 0"
    # Run your function
    run runDockerfileTests "replyTopic"
    # Check if it succeeds
    echo "$output"
    [ "$status" -eq 1 ]
    [[ "$output" == *"Dockerfile tests failed."* ]]
}

@test "runDockerfileTests should exit 0 if no tests are found" {
    # Stub gcloud builds submit command to return success
    stub yq "echo null"
    stub gcloud "exit 0"
    # Run your function
    run runDockerfileTests "replyTopic"
    # Check if it succeeds
    echo "$output"
    [ "$status" -eq 0 ]
    [[ "$output" == *"No test command found in pipeline.yaml."* ]]
}
