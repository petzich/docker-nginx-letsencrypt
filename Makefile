cwd=$(shell pwd)
DOCKER=sudo docker
IMAGE_TAG=petzi/nginx-letsencrypt
MAKE_IMAGE=petzi/alpine-make.local

.PHONY: default
default: build

.PHONY: build
build:
	$(DOCKER) build --tag ${IMAGE_TAG} .

.PHONY: build-make-image
build-make-image:
	$(DOCKER) build --tag ${MAKE_IMAGE} -f Dockerfile.alpine-make .

.PHONY: clean
clean:
	- $(DOCKER) rmi ${IMAGE_TAG}

.PHONY: test
test: build-make-image
	$(DOCKER) run -it --volume="${PWD}:/host" --rm ${MAKE_IMAGE} /host/test/run-tests.sh

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
