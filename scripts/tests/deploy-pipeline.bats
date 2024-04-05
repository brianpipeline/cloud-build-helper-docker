#!/usr/bin/env bats

load $(pwd)/scripts/deploy-pipeline.sh
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

@test "deployPipelines should handle successful build submission" {
    # Stub gcloud builds submit command to return success
    stub gcloud "exit 0"
    stub yq "exit 0"
    # Run your function
    run deployPipelines
    # Check if it succeeds
    [ "$status" -eq 0 ]
    [[ "$output" == *"Pipeline deployed."* ]]
}

@test "deployPipelines should handle failed build submission" {
    # Stub gcloud builds submit command to return failure
    stub gcloud "exit 1"
    stub yq "exit 0"
    # Run your function
    run deployPipelines
    echo $output
    # Check if it fails
    [ "$status" -eq 1 ]
    [[ "$output" == *"Failed to update pipeline"* ]]
    echo $PATH
}

@test "deployPipelines should exit when yq cannot find required values in pipeline yaml" {
    # Stub gcloud builds submit command to return failure
    stub yq "exit 1"
    # Run your function
    run deployPipelines
    echo $output
    # Check if it fails
    [ "$status" -eq 1 ]
    [[ "$output" == *"pipeline.yaml is missing pipelineType or pipelineName"* ]]
    echo $PATH
}
