#!/bin/bash -e
IMAGE_NAME=$1
TAG=$2
./gradlew clean
./gradlew assemble
docker build -t ${IMAGE_NAME}:${TAG} ftgo-application/