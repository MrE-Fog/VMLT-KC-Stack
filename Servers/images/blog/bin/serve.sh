#!/usr/bin/env bash

docker-compose up -d mongo_service
echo "Sleeping for 10 seconds"
sleep 10
echo "Starting Application Server"
export DB_USER="root"
export DB_USER_PASSWORD="a7dk59rj3-"
export DB_SERVER="localhost"
export DATABASE="socialbird"
swift run Run serve --env product --hostname 0.0.0.0 --port 8080 && \
docker-compose down && \
docker volume rm $(docker volume ls -qf dangling=true)

