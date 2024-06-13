#!/bin/bash
set -e

# Define o file-max no "host" para corrigir os erros de ulimit do appserver
sudo sysctl -w fs.file-max=32768

# Sobe a stack do protheus (banco, dbaccess, appserver, )
docker compose -f ci/docker/docker-compose.yml -p protheus up -d

# Aguarda alguns segundos por garantia
sleep 10

# Confere se os artefatos estão no container
docker compose -p protheus exec -i appserver /bin/sh -c "ls -lah /opt/totvs/protheus/apo/"
docker compose -p protheus exec -i appserver /bin/sh -c "ls -lah /opt/totvs/protheus/protheus_data/systemload/"

echo "Protheus Started"
