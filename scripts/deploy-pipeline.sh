#!/bin/bash
source send-message.sh
deployPipelines() {
    projectId="$1"
    replyTopic="$2"
    git_ref="$3"
    if [[ $git_ref != "refs/heads/main" ]]; then
        echo "Skipping pipeline deployment, as we are not on the main branch."
        exit 0
    fi

    if ! (yq eval '.pipelineType' "pipeline.yaml" && yq eval '.pipelineName' "pipeline.yaml"); then
        echo "pipeline.yaml is missing pipelineType or pipelineName"
        exit 1
    fi
    pipelineName=$(yq eval '.pipelineName' "pipeline.yaml")
    pipelineType=$(yq eval '.pipelineType' "pipeline.yaml")
    pubSubTopic=""
    webhookSecret=""
    if [[ $pipelineType == "pubsub" ]]; then
        if gcloud pubsub topics describe "$pipelineName" >/dev/null 2>&1; then
            echo "Topic $pipelineName already exists."
        else
            echo "Creating topic $pipelineName"
            if ! gcloud pubsub topics create "$pipelineName"; then
                echo "Failed to create topic $pipelineName"
                sendMessage "$replyTopic" "Pipeline failed."
                exit 1
            fi
        fi
        pubSubTopic="--topic=projects/${projectId}/topics/$pipelineName"
    fi
    if [[ $pipelineType == "webhook" ]]; then
        webhookSecret="--secret=projects/${projectId}/secrets/webhook-secret/versions/1"
    fi
    substitutions=$(yq eval '.substitutions' "cloudbuild.yaml")
    substitutionsInOneLine=""
    for substitution in $substitutions; do
        # Check if the final character is ":"
        if [ "${substitution: -1}" = ":" ]; then
            # If it is, replace ":" with "=" using parameter expansion
            substitution="${substitution%?}="
        fi
        if [[ $substitution =~ [\)\""}"]$ ]]; then
            substitutionsInOneLine="$substitutionsInOneLine$substitution,"
        else
            substitutionsInOneLine="$substitutionsInOneLine$substitution"
        fi
    done
    substitutionsInOneLine="${substitutionsInOneLine%,}"
    if [[ -z "$(gcloud builds triggers describe "$pipelineName" --region=us-central1 2>&1 >/dev/null)" ]]; then
        echo "Pipeline $pipelineName already exists. Updating."
        temp_file=$(mktemp)
        yq eval 'del(.substitutions)' "cloudbuild.yaml" >"$temp_file"
        if ! (gcloud builds triggers update "$pipelineType" "$pipelineName" --region="us-central1" --clear-substitutions --inline-config="$temp_file" && gcloud builds triggers update "$pipelineType" "$pipelineName" --region="us-central1" --update-substitutions "$substitutionsInOneLine" --inline-config="$temp_file"); then
            echo "Failed to update pipeline $pipelineName"
            sendMessage "$replyTopic" "Pipeline failed."
            exit 1
        fi
    else
        echo "Creating pipeline $pipelineName"
        if ! gcloud builds triggers create "$pipelineType" --name="$pipelineName" "$webhookSecret" --region="us-central1" --inline-config="cloudbuild.yaml" --substitutions "$substitutionsInOneLine" $pubSubTopic; then
            echo "Failed to create pipeline $pipelineName"
            sendMessage "$replyTopic" "Pipeline failed."
            exit 1
        fi
    fi

    echo "Pipeline deployed."
}
