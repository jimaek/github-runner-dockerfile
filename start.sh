#!/bin/bash

echo "ORG ${ORG}"
echo "ACCESS_TOKEN ${ACCESS_TOKEN}"

REG_TOKEN=$(curl -X POST -H "Authorization: Bearer ${ACCESS_TOKEN}" -H "Accept: application/vnd.github+json" https://api.github.com/orgs/${ORG}/actions/runners/registration-token | jq .token --raw-output)

echo "REG_TOKEN ${REG_TOKEN}"

cd /home/docker/actions-runner

./config.sh --url https://github.com/${ORG} --token ${REG_TOKEN} --replace

cleanup() {
    echo "Removing runner..."
    ./config.sh remove --unattended --token ${REG_TOKEN}
}

trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM

./run.sh & wait $!
