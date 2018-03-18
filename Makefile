COMPOSE=sudo docker-compose
DOCKER=sudo docker
TEST=test/docker-compose.yml

.PHONY: default
default: build test

.PHONY: build
build:
	$(COMPOSE) build
	$(COMPOSE) -f $(TEST) build

.PHONY: clean
clean:
	$(COMPOSE) down -v
	- $(COMPOSE) -f $(TEST) down -v
	- $(DOCKER) rmi test_test-backend
	- $(DOCKER) rmi test_test
	- $(DOCKER) rmi petzi/nginx-letsencrypt

.PHONY: test
test:
	$(COMPOSE) -f $(TEST) down -v
	$(COMPOSE) -f $(TEST) run test nginx -t
	$(COMPOSE) -f $(TEST) down -v

.PHONY: shell
shell:
	echo "entering test machine with /bin/sh"
	$(COMPOSE) -f $(TEST) down -v
	$(COMPOSE) -f $(TEST) up -d
	$(COMPOSE) -f $(TEST) exec test /bin/sh
	$(COMPOSE) -f $(TEST) down -v

.PHONY: run
run:
	$(COMPOSE) -f $(TEST) down -v
	$(COMPOSE) -f $(TEST) up
	$(COMPOSE) -f $(TEST) down -v

.PHONY: plain-shell
plain-shell:
	$(DOCKER) run -it --entrypoint /bin/sh petzi/nginx-letsencrypt
