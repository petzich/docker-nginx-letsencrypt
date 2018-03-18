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

.PHONY: shell
shell: build
	$(DOCKER) run -it --rm --entrypoint /bin/sh ${IMAGE_TAG}
