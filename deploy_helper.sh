#!/bin/bash

set -euo pipefail

if [[ "${DEBUG:-false}" = true ]]; then
    set -x
fi
# if CI is true or TRUE echo Running in CI
if [ -z ${CI+x} ]; then
    echo "Running locally"
else
    echo "Running in CI"
fi

tmp_manifest="$(mktemp)"

clean_tmp_manifest() {
    LAST_COMMAND_EXIT_STATUS=$?
    if [ -z ${CI+x} ]; then
        if [ $LAST_COMMAND_EXIT_STATUS -ne 0 ]; then
            if prompt "Do you want to clean the temporary manifest"; then
                rm -f "$tmp_manifest"
                echo "$tmp_manifest has been removed"
            fi
        else
            rm -f "$tmp_manifest"
            echo "$tmp_manifest has been removed"
        fi
    else
        echo "CI::Last command exit status: $LAST_COMMAND_EXIT_STATUS"
    fi
    exit $LAST_COMMAND_EXIT_STATUS
}

trap clean_tmp_manifest EXIT


replace_vars() {
    filepath=$1
    TIMESTAMP=$(date +%s)
    tmp_manifest=$(mktemp) # Create a temporary file for the modified manifest

    sed -e "
        s|\${ENV}|${ENV:-}|g
        s|\${BRANCH_NAME}|${BRANCH_NAME:-}|g 
        s|\${TENANT_NAMESPACE}|${TENANT_NAMESPACE:-}|g 
        s|\${DEPLOYMENT_NAME}|${DEPLOYMENT_NAME:-}|g 
        s|\${PROJECT}|${PROJECT:-}|g 
        s|\${DOCKER_IMAGE}|${DOCKER_IMAGE:-}|g 
        s|\${TIMESTAMP}|$TIMESTAMP|g 
        s|\${VERSION}|${VERSION:-}|g
    " "$filepath" > "$tmp_manifest"

    echo "$tmp_manifest"
}

deploy(){
    deployfile=$(replace_vars "$1")
    kubectl apply -f "$deployfile" -n "$TENANT_NAMESPACE"
}

destroy(){
    deployfile=$(replace_vars "$1")
    kubectl delete -f "$deployfile" -n "$TENANT_NAMESPACE"
}

status_check(){
    deployfile=$(replace_vars "$1")
    if grep -q "kind: Deployment" "$deployfile"; then
        kubectl rollout status -w "deployment/${DEPLOYMENT_NAME}" --timeout 3m -n "$TENANT_NAMESPACE"
    fi
}

deploy_prompt() {
    filepath=$1
    filename="$(basename "$filepath")"
    if prompt "Do you want to deploy $filename to k8s"; then
        deploy "$filepath" 
        status_check "$filepath"
    fi
}

destroy_prompt() {
    filepath=$1
    filename="$(basename "$filepath")"
    if prompt "Do you want to delete $filename"; then
        destroy "$filepath"
    fi
}

deploy_all(){
    for filepath in "$MANIFEST_SOURCE"/*
    do
        if [ -z ${CI+x} ]; then
            deploy_prompt "$filepath"
        else
            deploy "$filepath"
            status_check "$filepath"
        fi
    done
}

destroy_all(){
    for filepath in "$MANIFEST_SOURCE"/*
    do
        if [ -z ${CI+x} ]; then
            destroy_prompt "$filepath" 
        else
            replace_vars "$filepath"
            destroy
        fi
    done
}

case ${1} in
deploy_all) deploy_all ;;
destroy_all) destroy_all ;;
*)
    echo "Function not implemented."
    exit 1
    ;;
esac
