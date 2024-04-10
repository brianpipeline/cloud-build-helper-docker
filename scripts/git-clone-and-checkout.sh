#!/bin/bash
cloneAndCheckoutBranch() {
    clone_url=$1
    repo_name=$2
    ref=$3
    commit_sha=$4
    branch_name=$(echo "$ref" | sed 's/refs\/heads\///')

    git clone "$clone_url"
    cd "$repo_name"
    if [ "$commit_sha" == "" ]; then
        git checkout "$branch_name"
    else
        git checkout "$commit_sha"
    fi

}
