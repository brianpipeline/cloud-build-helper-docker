#!/usr/bin/env bats

load $(pwd)/send-message.sh
load $(pwd)/run-cloudbuild-tests.sh
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

@test "runCloudBuildTests should exit 0 when submissions.sh file exits 0." {
    # Stub gcloud builds submit command to return success
    stub gcloud "exit 0"
    # Run your function
    run runCloudBuildTests "topic"
    # Check if it succeeds
    echo "$output"
    [ "$status" -eq 0 ]
}

@test "runCloudBuildTests should exit 1 when submissions.sh file exits 1." {
    # Stub gcloud builds submit command to return success
    stub gcloud "exit 1"
    # Run your function
    run runCloudBuildTests "topic"
    # Check if it succeeds
    [ "$status" -eq 1 ]
}
