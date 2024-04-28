#!/bin/bash

sudo chmod 777 /home/docker/actions-runner/_work
sudo modprobe ip_tables
sudo pkill -9 -f dockerd
sudo pkill -9 -f containerd

echo "ORG ${ORG}"
echo "ACCESS_TOKEN ${ACCESS_TOKEN}"

REG_TOKEN=$(curl -X POST -H "Authorization: Bearer ${ACCESS_TOKEN}" -H "Accept: application/vnd.github+json" https://api.github.com/orgs/${ORG}/actions/runners/registration-token  2>/dev/null | jq -r '.token')

echo "REG_TOKEN ${REG_TOKEN}"

cd /home/docker/actions-runner

cleanup() {
    echo "Removing runner..."
    ./config.sh remove --token ${REG_TOKEN}
    sudo pkill -9 -f dockerd
    sudo pkill -9 -f containerd
}

echo "cleanup..."
cleanup

echo "starting docker..."
sudo dockerd --registry-mirror http://192.168.1.51:5000 > /home/docker/docker.log 2>&1 &

sleep 2

pidof  dockerd >/dev/null
if [[ $? -ne 0 ]] ; then
        echo "Failed to start. Killing and restarting the whole container"
        sudo exit 1
fi

echo "config.sh running..."
./config.sh --url https://github.com/${ORG} --token ${REG_TOKEN} --replace --unattended

trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM
trap 'cleanup; exit 1' TERM
trap 'cleanup; exit 0' TERM

echo "run.sh running..."
./run.sh & wait $!
