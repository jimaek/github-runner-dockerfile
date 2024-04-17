#!/bin/bash

sudo chmod 777 /home/docker/actions-runner/_work
sudo modprobe ip_tables
sudo pkill -9 -f dockerd
sudo pkill -9 -f containerd
sudo dockerd > /home/docker/docker.log 2>&1 &

echo "ORG ${ORG}"
echo "ACCESS_TOKEN ${ACCESS_TOKEN}"

REG_TOKEN=$(curl -X POST -H "Authorization: Bearer ${ACCESS_TOKEN}" -H "Accept: application/vnd.github+json" https://api.github.com/orgs/${ORG}/actions/runners/registration-token  2>/dev/null | jq -r '.token')

echo "REG_TOKEN ${REG_TOKEN}"

cd /home/docker/actions-runner

cleanup() {
    echo "Removing runner..."
    ./config.sh remove --token ${REG_TOKEN}
}

cleanup

./config.sh --url https://github.com/${ORG} --token ${REG_TOKEN} --replace --unattended

trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM

./run.sh & wait $!
