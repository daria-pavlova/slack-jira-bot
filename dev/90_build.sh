#!/usr/bin/env bash

set -euox pipefail

this="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
. "$this/SETUP.sh"
# shellcheck disable=SC1091
. "$this/../common-scripts/common.sh"

function ask_prompt(){
    if prompt "Do you want build docker image & push"; then
        build_and_push_docker
    elif prompt "Do you want to build docker image"; then
        build_local_docker
    fi
}

function build_and_push_docker(){
    "$this/../build_helper.sh" build_and_push_docker
}

function build_local_docker(){
    "$this/../build_helper.sh" build_docker
}

function build_kaniko(){
    "$this/../build_helper.sh" build_kaniko
}

if [ $# -eq 0 ]; then
    ask_prompt
elif [ "$1" = "build_local_docker" ]; then
    build_local_docker
elif [ "$1" = "build_and_push_docker" ]; then
    build_and_push_docker
elif [ "$1" = "build_kaniko" ]; then
    build_kaniko
else
    echo "Unknown argument: $1"
    exit 1
fi
