#!/bin/bash
set -e

sudo sysctl -w fs.file-max=32768

docker compose -f ci/docker/docker-compose.yml -p protheus up -d

sleep 10

docker compose -p protheus exec -i appserver /bin/sh -c "ls -lah /opt/totvs/protheus/apo/"
docker compose -p protheus exec -i appserver /bin/sh -c "ls -lah /opt/totvs/protheus/protheus_data/systemload/"

echo "Protheus Started"
