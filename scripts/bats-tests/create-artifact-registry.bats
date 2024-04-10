#!/usr/bin/env bats

load $(pwd)/create-artifact-registry.sh
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

@test "createArtifactRegistry should successfully create an artifact registry" {
    # Stub gcloud builds submit command to return success
    stub gcloud "exit 0"
    stub yq "echo test-repo"
    # Run your function
    run createArtifactRegistry
    # Check if it succeeds
    [ "$status" -eq 0 ]
    [[ "$output" == *"Artifact Registry test-repo already exists."* ]]
}

@test "createArtifactRegistry should fail to create an artifact registry" {
    # Stub gcloud builds submit command to return success
    stub gcloud "exit 1"
    stub yq "echo test-repo"
    # Run your function
    run createArtifactRegistry
    # Check if it succeeds
    [ "$status" -eq 1 ]
    [[ "$output" == *"Failed to create Artifact Registry test-repo"* ]]
}
