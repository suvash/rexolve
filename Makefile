.DEFAULT_GOAL:=help
SHELL:=/usr/bin/env bash

##@ Help

help:  ## Show this message
	@awk '\
	BEGIN {FS = ":.*##"} \
	/^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } \
	/^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } \
	' $(MAKEFILE_LIST)


export HOST_USER_ID:=$(shell id -u)
export HOST_GROUP_ID:=$(shell id -g)

DOCKER_COMPOSE := docker-compose -f compose.yml
DOCKER_COMPOSE_RUN_LAB := $(DOCKER_COMPOSE) run --rm lab

##@ Start/Stop/Restart

.PHONY: start stop

start: ## Start all the project service containers daemonised (Logs are tailed by a separate command)
	$(DOCKER_COMPOSE) up -d

stop: ## Stop all the project service containers
	$(DOCKER_COMPOSE) down --volumes


##@ Logging

.PHONY: logs

logs: ## Tail the logs for the project service containers (Filtered via SERVICE_NAME, eg. make tail-logs SERVICE_NAME=lab)
	$(if $(SERVICE_NAME), $(info -- Tailing logs for $(SERVICE_NAME)), $(info -- Tailing all logs, SERVICE_NAME not set.))
	$(DOCKER_COMPOSE) logs -f $(SERVICE_NAME)


##@ Cleanup

.PHONY: prune

prune: ## Cleanup dangling/orphaned docker resources
	docker system prune --volumes -f
