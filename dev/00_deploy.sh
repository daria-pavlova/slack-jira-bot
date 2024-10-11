#!/usr/bin/env bash

if [[ "${DEBUG:-false}" = true ]]; then
    set -x
fi

set -euo pipefail

this="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
. "$this/SETUP.sh"


if [ -z ${CI+x} ]; then 
    # shellcheck disable=SC1091
    . "$this/../common-scripts/common.sh"

    export -f prompt
fi


"$this/../deploy_helper.sh" deploy_all
