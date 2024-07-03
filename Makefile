.PHONY:	clean image publish tag test vars

VERSION?=2.3.15


ACCOUNT?=$(shell aws sts get-caller-identity | jq -r .Account)
AWS_REGION?=eu-west-1
ECR?=${ACCOUNT}.dkr.ecr.eu-west-1.amazonaws.com
NAME?=$(shell awk -F: '$$1=="name" {print $$2}' deployment.yaml | sed -e 's/[[:blank:]]//g')
SHORTNAME?=$(shell echo ${NAME} | cut -f2 -d/)
STAGE?=dev

COMMIT=$(shell git rev-parse --short HEAD)
TAG?=$(shell printf '%s_%s_%08d' ${VERSION} ${COMMIT} ${GITHUB_RUN_NUMBER})

${TAG}:
	@echo ${TAG}

IMAGE?=${NAME}/${STAGE}
REPO?=${ECR}/${IMAGE}


all: image

clean:
	@echo

image:
	@echo Building ${NAME}:${TAG} ...
	@docker build --build-arg REGISTRY_VERSION=$(VERSION) \
		--tag ${NAME}:${TAG} \
		.
	@echo Done.

publish: image
	@echo Publishing image: ${REPO}:${TAG} ...
	@docker tag ${NAME}:${TAG} ${REPO}:${TAG}
	@docker push ${REPO}:${TAG} 2>&1
	@echo Done.

realclean: clean
	@rm -f ${GITHUB_TOKEN} ${BUNDLE_CFG}

tag:
	@echo ${TAG}

vars:
	@echo "Docker: ${REPO}:${TAG}"
	@echo "ACCOUNT = ${ACCOUNT}"
	@echo "ECR = ${ECR}"
	@echo "NAME = ${NAME}"
	@echo "STAGE = ${STAGE}"
	@echo "COMMIT = ${COMMIT}"
	@echo "TAG = ${TAG}"
	@echo "VERSION = ${VERSION}"
