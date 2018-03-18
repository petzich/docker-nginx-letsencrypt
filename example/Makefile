COMPOSE=sudo docker-compose
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
	$(COMPOSE) down -v
	$(COMPOSE) run --rm test nginx -t
	$(COMPOSE) down -v

.PHONY: shell
shell: build
	echo "entering test machine with /bin/sh"
	$(COMPOSE) down -v
	$(COMPOSE) up -d
	$(COMPOSE) exec test /bin/sh
	$(COMPOSE) down -v

.PHONY: run
run: build
	$(COMPOSE) down -v
	$(COMPOSE) up
	$(COMPOSE) down -v
