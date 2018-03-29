cwd=$(shell pwd)
DOCKER=sudo docker
IMAGE_TAG=petzi/nginx-letsencrypt
TEST_IMAGE=alpine:3.7

.PHONY: default
default: build

.PHONY: build
build:
	$(DOCKER) build --tag ${IMAGE_TAG} .

.PHONY: clean
clean:
	- $(DOCKER) rmi ${IMAGE_TAG}

.PHONY: test
test:
	$(DOCKER) run -it --volume="${PWD}:/host" --rm ${TEST_IMAGE} /host/test/run-tests.sh

# A minimal integration test
.PHONY: integration-test
integration-test: clean build
	$(DOCKER) run -it --rm \
		-e "PROXY_MODE=dev" \
		-e "PROXY_DOMAIN=localhost" \
		-e "PROXY_BACKENDS=localhost localhost" \
		-e "ENTRYPOINT_LOGLEVEL=DEBUG" \
		${IMAGE_TAG} nginx -t

.PHONY: shell
shell: build
	$(DOCKER) run -it --rm --entrypoint /bin/sh ${IMAGE_TAG}
