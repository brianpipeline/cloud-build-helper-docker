#!/usr/bin/env bats

load $(pwd)/send-message.sh
load $(pwd)/trigger-pipelines.sh
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

@test "triggerPipelines should exit 1 when it receives a bad repo type" {
    # Stub gcloud builds submit command to return success
    stub gcloud "exit 0"
    stub yq "echo 'badType'"
    # Run your function
    run triggerPipelines "cloneUrl" "repoName" "refs/heads/main" "headSha" "buildId" "projectId"
    # Check if it succeeds
    [ "$status" -eq 1 ]
    [[ "$output" == *"Unknown repo type: "* ]]
}

@test "triggerPipelines should exit 0 when it receives a valid repo type" {
    # Stub gcloud builds submit command to return success
    stub gcloud "exit 0"
    stub yq "echo 'dockerfile-deploy'"
    # Run your function
    run triggerPipelines "cloneUrl" "repoName" "refs/heads/main" "headSha" "buildId" "projectId"
    # Check if it succeeds
    [ "$status" -eq 0 ]
    [[ "$output" == *"Pipeline triggered."* ]]
}