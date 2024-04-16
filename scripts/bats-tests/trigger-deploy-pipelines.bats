#!/usr/bin/env bats
load $(pwd)/trigger-deploy-pipelines.sh

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

@test "triggerDeployPipelines should exit 0 when everything succeeds" {
    stub gcloud "echo 'Pipeline succeeded.'"
    stub yq "echo java21"
    stub grep "echo hello"
    # Run your function
    run triggerDeployPipelines "refs/heads/main" "projectId" "abcdefgh" "20" "replyTopic"
    # Check if it succeeds
    [ "$status" -eq 0 ]
    [[ "$output" == *"All deployments completed."* ]]
}

@test "triggerDeployPipelines should exit 1 when it has an invalid project type" {
    stub gcloud "echo 'Pipeline succeeded.'"
    stub yq "echo invalid"
    stub grep "echo hello"
    # Run your function
    run triggerDeployPipelines "refs/heads/main" "projectId" "abcdefgh" "20" "replyTopic"
    # Check if it succeeds
    [ "$status" -eq 1 ]
    [[ "$output" == *"Not a valid project type, not deploying."* ]]
}

@test "triggerDeployPipelines should exit 0 when branch is not main or release" {
    stub gcloud "echo 'Pipeline succeeded.'"
    stub yq "echo java21"
    stub grep "echo hello"
    # Run your function
    run triggerDeployPipelines "refs/heads/feature" "projectId" "abcdefgh" "20" "replyTopic"
    # Check if it succeeds
    [ "$status" -eq 0 ]
    [[ "$output" == *"Not on main or release branch, skipping deployment."* ]]
}
