DOCKER=sudo docker
IMAGE_TAG=petzi/nginx-letsencrypt

.PHONY: default
default: build

.PHONY: build
build:
	$(DOCKER) build --tag ${IMAGE_TAG} .

.PHONY: clean
clean:
	- $(DOCKER) rmi ${IMAGE_TAG}

.PHONY: test
test: clean build
	echo "TODO"

# A minimal integration test
.PHONY: integration-test
integration-test: clean build
	$(DOCKER) run -it --rm \
		-e "PROXY_MODE=dev" \
		-e "PROXY_DOMAIN=localhost" \
		-e "PROXY_BACKENDS=localhost" \
		-e "ENTRYPOINT_LOGLEVEL=4" \
		${IMAGE_TAG} nginx -t

.PHONY: shell
shell: build
	$(DOCKER) run -it --rm --entrypoint /bin/sh ${IMAGE_TAG}
