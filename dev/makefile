UNAME:= $(shell uname)
ifeq ($(UNAME),Darwin)
		OS_X  := true
		SHELL := /bin/bash
else
		OS_DEB  := true
		SHELL := /bin/bash
endif


default:
	@echo "makefile for build and deploy"
	@echo "The following targets are available:"
	@echo "	buildlocal			builds the docker locally"
	@echo "	buildpush			builds the docker and pushes it to the registry"
	@echo " deploy 				interactive deploy to caas"
	@echo " init 				initializes the project" 

buildlocal:
	@echo "building docker locally"
	./09_build.sh build_local_docker

buildpush:
	@echo "building docker and pushing to registry"
	./09_build.sh build_and_push_docker

deploy:
	@echo "deploying application to CaaS"
	./00_deploy.sh
