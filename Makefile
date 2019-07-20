# local.image (without tag)
IMAGE_NAME=roeldev/php-nginx
# local.container_name
CONTAINER_NAME=php-nginx
# local.build.args.PHP_VERSION
DEFAULT_PHP_VERSION=7.1

.PHONY it:
it: build tag start

.PHONY build:
build:
	docker-compose build local

.PHONY start:
start:
	docker-compose up local

.PHONY stop:
stop:
	docker stop ${CONTAINER_NAME}

.PHONY kill:
kill: stop
	docker rm ${CONTAINER_NAME}

.PHONY restart:
restart: stop start

.PHONY inspect:
inspect:
	docker inspect ${IMAGE_NAME}:local

.PHONY tag:
tag:
	docker tag ${IMAGE_NAME}:local ${IMAGE_NAME}:${DEFAULT_PHP_VERSION}-v1

.PHONY login:
login:
	docker exec -it ${CONTAINER_NAME} bash

.PHONY renew:
renew:
	docker pull roeldev/php-cli:${DEFAULT_PHP_VERSION}-v1
