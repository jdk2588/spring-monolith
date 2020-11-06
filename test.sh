#! /bin/bash -e

DATABASE_SERVICES="mysql"

if [ -z "$DOCKER_COMPOSE" ] ; then
    DOCKER_COMPOSE=docker-compose
fi

./gradlew testClasses

${DOCKER_COMPOSE?} down --remove-orphans -v

./gradlew $* integrationTest