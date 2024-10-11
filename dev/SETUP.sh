#!/usr/bin/env bash

set -euo pipefail

if [[ "${DEBUG:-false}" = true ]]; then
  set -x
fi

BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CI_PROJECT_DIR="$( cd "$BASE_DIR/../" && pwd )"
BRANCH_NAME=${CI_COMMIT_REF_SLUG:-$(git rev-parse --abbrev-ref HEAD)}
BRANCH_NAME=${BRANCH_NAME//[^a-zA-Z0-9-]/-}
BRANCH_NAME=${BRANCH_NAME//[-]+/-}


export BASE_DIR
export BRANCH_NAME
export CI_PROJECT_DIR
export ENV=dev
export TENANT_NAMESPACE="slack-jira-bot"
export DEPLOYMENT_NAME="slack-jira-bot-$ENV"
export DOCKER_DEFAULT_PLATFORM=linux/amd64
export PROJECT="slack-jira-bot"
export DEPLOYMENT_ECHO="echo"
export DOCKER_IMAGE="franksword/slack-jira-bot:$BRANCH_NAME"
export MANIFEST_SOURCE="$BASE_DIR/k8s"
