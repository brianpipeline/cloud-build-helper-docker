#!/usr/bin/env bats

load $(pwd)/send-message.sh
load "$(pwd)/deploy-to-cloud-run.sh"

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

@test "deployToCloudRun should successfully deploy artifact." {
    stub gcloud "exit 0"
    stub yq "echo java21"
    # Run your function
    run deployToCloudRun "replyTopic" "testRepo" "projectId" "1.0.0" "dev" "serviceAccountcloud-run@cloud-build-pipeline-396819.iam.gserviceaccount.com"
    # Check if it succeeds
    [ "$status" -eq 0 ]
    [[ "$output" == *"Cloud Run deployment succeeded."* ]]
}

@test "deployToCloudRun exits 1 when it receives weird pipeline type." {
    stub gcloud "exit 0"
    stub yq "echo weird"
    # Run your function
    run deployToCloudRun "replyTopic" "testRepo" "projectId" "1.0.0" "dev" "serviceAccountcloud-run@cloud-build-pipeline-396819.iam.gserviceaccount.com"
    # Check if it succeeds
    [ "$status" -eq 1 ]
    [[ "$output" == *"Unknown project type: weird"* ]]
}

@test "deployToCloudRun exits 1 when it fails to deploy cloud run." {
    stub gcloud "exit 1"
    stub yq "echo java21"
    # Run your function
    run deployToCloudRun "replyTopic" "testRepo" "projectId" "1.0.0" "dev" "serviceAccountcloud-run@cloud-build-pipeline-396819.iam.gserviceaccount.com"
    # Check if it succeeds
    [ "$status" -eq 1 ]
    [[ "$output" == *"Failed to deploy to Cloud Run."* ]]
}
