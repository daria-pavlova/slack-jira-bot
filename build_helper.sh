#!/bin/bash

if [[ "${DEBUG:-false}" = true ]]; then
  set -x
fi
# set -euo pipefail

# cat "${CI_PROJECT_DIR-.}/build_args.env"

# while IFS= read -r line; do
#   opts+=(--build-arg "$line")
# done < "${CI_PROJECT_DIR-.}/build_args.env"

build() {
  if [[ "${CI:-false}" = true ]]; then
    build_kaniko
  else
    build_docker
  fi
}


build_docker() {
  pushd "${CI_PROJECT_DIR-.}" || cd "${CI_PROJECT_DIR-.}"
  docker build  -t "$DOCKER_IMAGE" . -f "${CI_PROJECT_DIR-.}/Dockerfile"
  echo "--------------------------------------"
  echo "Docker images"
  echo "  DOCS  : $DOCKER_IMAGE"
  echo "--------------------------------------"  
  popd || cd -
}

build_and_push_docker(){
  pushd "${CI_PROJECT_DIR-.}" || cd "${CI_PROJECT_DIR-.}"
  docker build  -t "$DOCKER_IMAGE"\
   . -f "${CI_PROJECT_DIR-.}/Dockerfile"
  docker push "$DOCKER_IMAGE"
  echo "--------------------------------------"
  echo "Docker images"
  echo "  DOCS: $DOCKER_IMAGE"  
  echo "--------------------------------------"  
  popd || cd -
}


docker_authentication(){
  mkdir -p "$HOME"/.docker
  cat > "$HOME/.docker/config.json" <<EOL
{
  "auths": {
    "${DOCKER_REGISTRY}": {
      "auth": "${DOCKER_AUTH}"
    }
  }
}
EOL

}

build_kaniko() {
mkdir -p /kaniko/.docker
cat >/kaniko/.docker/config.json <<EOL
{
  "auths": {
    "${DOCKER_REGISTRY}": {
      "auth": "${DOCKER_AUTH}"
    }
  }
}
EOL

/kaniko/executor \
  --context "$CI_PROJECT_DIR" \
  --dockerfile "$CI_PROJECT_DIR"/Dockerfile \
  --destination "$DOCKER_IMAGE"
}

case ${1} in
build)
  build
  ;;
build_and_push_docker)
  build_and_push_docker
  ;;
build_and_push_docker_ci)
  docker_authentication
  build_and_push_docker
  ;;
build_docker)
  build_docker
  ;;
build_kaniko)
  build_kaniko
  ;;
*)
  echo "Function not implemented: '${1}'"
  echo "build for automatic build"
  echo "build_docker for docker build"
  echo "build_kaniko for kaniko build"
  echo "build_and_push_docker for docker build and push"
  exit 1
  ;;
esac
