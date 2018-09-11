DOCKER_COMPOSE_FILE := my-docker-compose.yml

all: build startdb setup

sh:
	docker-compose -f ${DOCKER_COMPOSE_FILE} run cms -- sh

run:
	docker-compose -f ${DOCKER_COMPOSE_FILE} up

setup:
	docker-compose -f ${DOCKER_COMPOSE_FILE} run cms setup

startdb:
	docker-compose -f ${DOCKER_COMPOSE_FILE} start db

build:
	docker-compose -f ${DOCKER_COMPOSE_FILE} build

buildclean:
	docker-compose -f ${DOCKER_COMPOSE_FILE} build --no-cache

test: clean
	docker-compose -f ${DOCKER_COMPOSE_FILE} run cms testsetup test

check:
	rubocop

index: index_series index_stories

index_series:
	docker-compose -f ${DOCKER_COMPOSE_FILE} run cms -- bundle exec rake environment elasticsearch:import CLASS=Series FORCE=1

index_stories:
	docker-compose -f ${DOCKER_COMPOSE_FILE} run cms -- bundle exec rake environment elasticsearch:import CLASS=Story FORCE=1

clean:
	sudo rm -rf log/*log && chmod 777 log
	sudo rm -rf tmp/ && mkdir tmp && chmod -R 777 tmp
	sudo rm -rf coverage/ && mkdir coverage && chmod 777 coverage

onetest: clean
	docker-compose -f ${DOCKER_COMPOSE_FILE} run cms -- bundle exec rake test RAILS_ENV=test TEST=${TEST}

stop:
	docker-compose -f ${DOCKER_COMPOSE_FILE} stop

console:
	docker-compose -f ${DOCKER_COMPOSE_FILE} run cms console


.PHONY: test clean check all setup startdb build stop
