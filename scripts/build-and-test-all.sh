#! /bin/bash -e

KEEP_RUNNING=
ASSEMBLE_ONLY=
DATABASE_SERVICES="mysql"

if [ -z "$DOCKER_COMPOSE" ] ; then
    DOCKER_COMPOSE=docker-compose
fi

while [ ! -z "$*" ] ; do
  case $1 in
    "--keep-running" )
      KEEP_RUNNING=yes
      ;;
    "--assemble-only" )
      ASSEMBLE_ONLY=yes
      ;;
    "--help" )
      echo ./build-and-test-all.sh --keep-running --assemble-only
      exit 0
      ;;
  esac
  shift
done

echo KEEP_RUNNING=$KEEP_RUNNING

. ./set-env.sh

# TODO Temporarily

./gradlew testClasses

${DOCKER_COMPOSE?} down --remove-orphans -v
${DOCKER_COMPOSE?} up -d --build ${DATABASE_SERVICES?}

./gradlew waitForMySql

echo mysql is started

./gradlew :ftgo-flyway:flywayMigrate

if [ -z "$ASSEMBLE_ONLY" ] ; then

  ./gradlew -x :ftgo-end-to-end-tests:test $* build

  ${DOCKER_COMPOSE?} build

  ./gradlew $* integrationTest

  ${DOCKER_COMPOSE?} up -d
else

  ./gradlew $* assemble

  ${DOCKER_COMPOSE?} up -d --build ${DATABASE_SERVICES?}

  ./gradlew waitForMySql

  echo mysql is started

  ${DOCKER_COMPOSE?} up -d --build
fi

./wait-for-services.sh

./run-end-to-end-tests.sh

if [ -z "$KEEP_RUNNING" ] ; then
  ${DOCKER_COMPOSE?} down --remove-orphans -v
fi
