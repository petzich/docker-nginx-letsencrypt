cwd=$(shell pwd)
DOCKER=sudo docker
IMAGE_TAG=petzi/nginx-letsencrypt
COVERAGE_IMAGE=ragnaroek/kcov_head
COVERAGE_DIR=.coverage

.PHONY: default
default: build

.PHONY: build
build:
	$(DOCKER) build --tag ${IMAGE_TAG} .

.PHONY: clean
clean:
	- sudo rm -rf ${COVERAGE_DIR}
	- $(DOCKER) rmi ${IMAGE_TAG}

.PHONY: test
test: build
	$(DOCKER) run -it \
		--volume="${PWD}:/source" \
		--entrypoint="/bin/sh" \
		--rm \
		${IMAGE_TAG} \
		/source/test/run-tests.sh

# --bash-handle-sh-invocation is required, so kcov follows all shell scripts executed
# in the for loop in the run-tests.sh wrapper script
.PHONY: coverage
coverage:
	echo "WARNING: coverage support is experimental and does not produce valubale output yet."
	$(DOCKER) run -it \
		--volume="${PWD}:/source" \
		--rm \
		${COVERAGE_IMAGE} \
		--bash-method=DEBUG \
		--include-pattern=/source/lib/,/source/test/ \
		/source/${COVERAGE_DIR} \
		/source/test/run-tests.sh

# A minimal integration test
.PHONY: integration-test
integration-test: build
	$(DOCKER) run -it \
		--rm \
		-e "PROXY_MODE=dev" \
		-e "PROXY_DOMAIN=localhost" \
		-e "PROXY_BACKENDS=localhost localhost" \
		-e "ENTRYPOINT_LOGLEVEL=DEBUG" \
		${IMAGE_TAG} nginx -t

.PHONY: shell
shell: build
	$(DOCKER) run -it \
		--rm \
		--entrypoint="/bin/sh" \
		${IMAGE_TAG}
