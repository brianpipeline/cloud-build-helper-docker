#!/usr/bin/env bats

load $(pwd)/send-message.sh
load $(pwd)/build-and-push-docker.sh
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

@test "buildAndPushDocker should successfully build and push" {
    # Stub gcloud builds submit command to return success
    stub docker "exit 0"
    stub yq "echo hello"
    # Run your function
    run buildAndPushDocker "replyTopic" "project_id" "refs/heads/main"
    # Check if it succeeds
    [ "$status" -eq 0 ]
    echo "output: $output"
    echo "hello"
    [[ "$output" == *"Docker image us-central1-docker.pkg.dev/project_id/hello/hello:hello built and pushed successfully."* ]]
}

@test "buildAndPushDocker should exit 1 when docker build fails" {
    # Stub gcloud builds submit command to return success
    stub docker "exit 1"
    stub yq "exit 0"
    # Run your function
    run buildAndPushDocker "replyTopic" "project_id" "refs/heads/main"
    # Check if it succeeds
    [ "$status" -eq 1 ]
    [[ "$output" == *"Failed to build Docker image."* ]]
}

@test "buildAndPushDocker should push when on release branch" {
    # Stub gcloud builds submit command to return success
    stub docker "exit 0"
    stub yq "echo hello"
    # Run your function
    run buildAndPushDocker "replyTopic" "project_id" "refs/heads/release/1.0"
    # Check if it succeeds
    [ "$status" -eq 0 ]
    [[ "$output" == *"Docker image us-central1-docker.pkg.dev/project_id/hello/hello:1.0 built and pushed successfully."* ]]
}
