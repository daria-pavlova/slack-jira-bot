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
    . "$this/../../roc-scripts/common.sh"

    # Login to the right ROC clusters and namespaces
    roc_login
    export -f prompt
fi

"$this/../../deploy_helper.sh" destroy_all