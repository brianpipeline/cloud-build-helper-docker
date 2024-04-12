#!/usr/bin/env bats

load $(pwd)/send-message.sh
load $(pwd)/create-cloud-storage-bucket.sh
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

@test "createCloudStorageBucket should fail to create bucket when gcloud fails" {
    # Stub gcloud builds submit command to return success
    stub gsutil "exit 1"
    stub gcloud "exit 0"
    # Run your function
    run createCloudStorageBucket "my_repo" "replyTopic"
    # Check if it succeeds
    [ "$status" -eq 1 ]
    [[ "$output" =~ "Bucket gs://my_repo_tf_state does not exist - creating bucket." && "$output" =~ "Failed to create bucket 'gs://my_repo_tf_state'." ]]
}

@test "createCloudStorageBucket should not create bucket when bucket already exists." {
    # Stub gcloud builds submit command to return success
    stub gsutil "exit 0"
    # Run your function
    run createCloudStorageBucket "my_repo" "replyTopic"
    # Check if it succeeds
    echo $output
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Bucket gs://my_repo_tf_state already exists." ]]
}

# I can't create any more tests without redoing how the stub function works. Not doing any more since we're moving to Python soon anyway.