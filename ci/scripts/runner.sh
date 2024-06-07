#!/bin/bash
set -e
# set -x

response=$(curl -L \
    -X POST \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer GITHUB_TOKEN" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    https://api.github.com/repos/totvs/protheus-ci-universo/actions/runners/registration-token)

token=$(echo $response | jq -r '.token')

docker run --rm -it --name runner -u 0:0 \
    -e GH_URL=https://github.com/totvs/protheus-ci-universo \
    -e GH_TOKEN=${token} \
    -e GH_WORKER_NAME=teste-tir \
    -e GH_LABELS=tir \
    -e RUNNER_ALLOW_RUNASROOT=true \
    -v /var/run/docker.sock:/var/run/docker.sock \
    ghcr.io/actions/actions-runner:2.317.0 \
    /bin/sh -x -c "./config.sh --unattended --url \$GH_URL --token \$GH_TOKEN --replace --name \$GH_WORKER_NAME --labels \$GH_LABELS && ./run.sh"