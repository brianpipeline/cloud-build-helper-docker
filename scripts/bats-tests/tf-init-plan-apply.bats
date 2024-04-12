#!/usr/bin/env bats

load $(pwd)/send-message.sh
load $(pwd)/tf-init-plan-apply.sh
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

@test "runTfInitPlanApply should fail when terraform init fails" {
    # Stub gcloud builds submit command to return success
    stub terraform "exit 1"
    # Run your function
    run runTfInitPlanApply "my_repo" "replyTopic"
    # Check if it succeeds
    [ "$status" -eq 1 ]
    [[ "$output" =~ "Terraform init failed." ]]
}

@test "runTfInitPlanApply should succeed when terraform init succeeds" {
    # Stub gcloud builds submit command to return success
    stub terraform "exit 0"
    # Run your function
    run runTfInitPlanApply "my_repo" "replyTopic"
    # Check if it succeeds
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Terraform init succeeded." ]]
}

# I can't create any more tests without redoing how the stub function works. Not doing any more since we're moving to Python soon anyway.
