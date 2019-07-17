# local.image (without tag)
IMAGE_NAME=roeldev/php-nginx
# local.container_name
CONTAINER_NAME=php-nginx

.PHONY it:
it: build tag start

.PHONY renew:
renew:
	docker pull roeldev/php-cli:7.1-v1

.PHONY build:
build:
	docker-compose build --force-rm local

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
	docker tag ${IMAGE_NAME}:local ${IMAGE_NAME}:v1

.PHONY login:
login:
	docker exec -it ${CONTAINER_NAME} bash
