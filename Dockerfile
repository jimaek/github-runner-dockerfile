FROM ubuntu:22.04

# Prevents installdependencies.sh from prompting the user and blocking the image creation
ARG DEBIAN_FRONTEND=noninteractive

RUN apt update -y && apt upgrade -y && useradd -m docker
RUN apt install -y --no-install-recommends \
    curl jq build-essential libssl-dev libffi-dev python3 python3-venv python3-dev python3-pip docker.io sudo


RUN cd /home/docker && mkdir actions-runner && cd actions-runner \
    && curl -sL $(curl -s https://api.github.com/repos/actions/runner/releases/latest | grep browser_download_url | cut -d\" -f4 | egrep 'linux-x64-[0-9.]+tar.gz$') | tar zx

RUN chown -R docker ~docker && /home/docker/actions-runner/bin/installdependencies.sh

COPY start.sh start.sh

# make the script executable
RUN chmod +x start.sh

# since the config and run script for actions are not allowed to be run by root,
# set the user to "docker" so all subsequent commands are run as the docker user
USER docker

ENTRYPOINT ["./start.sh"]
