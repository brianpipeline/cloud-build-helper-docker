#!/usr/bin/env bats

load $(pwd)/scripts/reply-to-queue.sh
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

@test "reply-to-queue should successfully push a message to a queue" {
    # Stub gcloud builds submit command to return success
    stub gcloud "exit 0"
    # Run your function
    run reply "topic" "hello"
    # Check if it succeeds
    [ "$status" -eq 0 ]
}
