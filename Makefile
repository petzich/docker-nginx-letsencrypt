COMPOSE=sudo docker-compose
DOCKER=sudo docker
TEST=test/docker-compose.yml

.PHONY: build clean default run shell test

default: build test

build:
	$(COMPOSE) build

clean:
	$(COMPOSE) down -v
	$(COMPOSE) -f $(TEST) down -v
	$(DOCKER) rmi test_test-backend

test:
	$(COMPOSE) -f $(TEST) down -v
	$(COMPOSE) -f $(TEST) run test nginx -t
	$(COMPOSE) -f $(TEST) down -v

shell:
	echo "entering test machine with /bin/sh"
	$(COMPOSE) -f $(TEST) down -v
	$(COMPOSE) -f $(TEST) up -d
	$(COMPOSE) -f $(TEST) exec test /bin/sh
	$(COMPOSE) -f $(TEST) down -v

run:
	$(COMPOSE) -f $(TEST) down -v
	$(COMPOSE) -f $(TEST) up
	$(COMPOSE) -f $(TEST) down -v

plain-shell:
	$(DOCKER) run -it --entrypoint /bin/sh petzi/nginx-letsencrypt
