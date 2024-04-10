#!/usr/bin/env bats

load $(pwd)/git-clone-and-checkout.sh
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

@test "cloneAndCheckoutBranch should exit 0 when git commands succeed." {
    # Stub gcloud builds submit command to return success
    stub git "exit 0"
    # Run your function
    run cloneAndCheckoutBranch "fake_url" "fake_repo_name" "fake_ref" "fake sha"
    # Check if it succeeds
    echo "$output"
    [ "$status" -eq 0 ]
}

@test "cloneAndCheckoutBranch should exit 1 when git commands fails." {
    # Stub gcloud builds submit command to return success
    stub git "exit 1"
    # Run your function
    run cloneAndCheckoutBranch "fake_url" "fake_repo_name" "fake_ref" "fake sha"
    # Check if it succeeds
    echo "$output"
    [ "$status" -eq 1 ]
}
