#!/bin/bash
deployPipelines() {
    if ! (yq eval '.pipelineType' "pipeline.yaml" && yq eval '.pipelineName' "pipeline.yaml"); then
        echo "pipeline.yaml is missing pipelineType or pipelineName"
        exit 1
    fi
    pipelineName=$(yq eval '.pipelineName' "pipeline.yaml")
    pipelineType=$(yq eval '.pipelineType' "pipeline.yaml")
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
    if [[ -z "$(gcloud builds triggers describe "$pipelineName" --region=us-central1 2>&1 >/dev/null)" ]]; then
        echo "Pipeline $pipelineName already exists. Updating."
        temp_file=$(mktemp)
        yq eval 'del(.substitutions)' "cloudbuild.yaml" >"$temp_file"
        if ! (gcloud builds triggers update "$pipelineType" "$pipelineName" --region="us-central1" --clear-substitutions --inline-config="$temp_file" && gcloud builds triggers update "$pipelineType" "$pipelineName" --region="us-central1" --update-substitutions "$substitutionsInOneLine" --inline-config="$temp_file"); then
            echo "Failed to update pipeline $pipelineName"
            exit 1
        fi
    else
        echo "Creating pipeline $pipelineName"
        if ! gcloud builds triggers create "$pipelineType" --name="$pipelineName" --secret="projects/212799175996/secrets/webhook-secret/versions/1" --region="us-central1" --inline-config="cloudbuild.yaml" --substitutions "$substitutionsInOneLine"; then
            echo "Failed to create pipeline $pipelineName"
            exit 1
        fi
    fi

    echo "Pipeline deployed."
}
