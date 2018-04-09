COMPOSE_VERSION=1.18.0
COMPOSE_FILE=${PWD}/docker-compose.yml
COMPOSE=sudo COMPOSE_FILE=${COMPOSE_FILE} docker run -it --rm --volume /var/run/docker.sock:/var/run/docker.sock --mount type=bind,source=${PWD},destination=${PWD},readonly -e COMPOSE_FILE docker/compose:${COMPOSE_VERSION}
DOCKER=sudo docker

.PHONY: default
default: clean build test

# We want to make sure we use the local petzi/nginx-letsencrypt image, so
# force a build of the image by calling make in the top-level directory of 
# the project.
.PHONY: build
build:
	$(MAKE) -C ../
	$(COMPOSE) build

.PHONY: clean
clean:
	$(COMPOSE) down -v
	- $(DOCKER) rmi petzi/nginx-letsencrypt.example.frontend
	- $(DOCKER) rmi petzi/nginx-letsencrypt.example.backend

.PHONY: test
test: clean build
	$(COMPOSE) down
	$(COMPOSE) run --rm test nginx -t
	$(COMPOSE) run --rm test nginx -t
	$(COMPOSE) down

.PHONY: shell
shell: build
	echo "entering test machine with /bin/sh"
	$(COMPOSE) down
	$(COMPOSE) up -d
	$(COMPOSE) exec test /bin/sh
	$(COMPOSE) down

.PHONY: run
run: build
	$(COMPOSE) down
	$(COMPOSE) up
	$(COMPOSE) down
