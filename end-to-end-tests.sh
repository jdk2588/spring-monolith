#! /bin/bash -e

DATABASE_SERVICES="mysql"

if [ -z "$DOCKER_COMPOSE" ] ; then
    DOCKER_COMPOSE=docker-compose
fi

${DOCKER_COMPOSE?} up -d --build ${DATABASE_SERVICES?}
./gradlew waitForMySql
./gradlew :ftgo-flyway:flywayMigrate
./gradlew -x :ftgo-end-to-end-tests:test $* build
${DOCKER_COMPOSE?} down --remove-orphans -v