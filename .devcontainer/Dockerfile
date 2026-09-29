FROM ubuntu:26.04@sha256:da6fc2be547864451aa253836dd926da33623312df4a9a243e35dc877c378a78

ENV DEBIAN_FRONTEND=noninteractive \
    ANSIBLE_VENV=/opt/ansible \
    PATH=/opt/ansible/bin:${PATH}

# Package versions are the resolute-updates builds current with this base digest.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates=20260601~26.04.1 \
        curl=8.18.0-1ubuntu2.7 \
        git=1:2.53.0-1ubuntu1 \
        rsync=3.4.1+ds1-7ubuntu0.3 \
        python3=3.14.3-0ubuntu2 \
        python3-pip=25.1.1+dfsg-1ubuntu2 \
        python3-venv=3.14.3-0ubuntu2 \
        sudo=1.9.17p2-1ubuntu3.1 \
    && rm -rf /var/lib/apt/lists/* \
    && python3 -m venv "${ANSIBLE_VENV}" \
    && "${ANSIBLE_VENV}/bin/pip" install --upgrade pip wheel

COPY requirements.txt /tmp/requirements.txt
COPY requirements.yml /tmp/requirements.yml
RUN "${ANSIBLE_VENV}/bin/pip" install -r /tmp/requirements.txt \
    && "${ANSIBLE_VENV}/bin/ansible-galaxy" collection install -r /tmp/requirements.yml \
    && rm /tmp/requirements.txt /tmp/requirements.yml

WORKDIR /workspace
# remoteUser is root for docker-in-docker. See .devcontainer/devcontainer.json.
# nosemgrep: dockerfile.security.missing-user.missing-user
CMD ["ansible", "--version"]
