FROM ubuntu:26.04

ENV DEBIAN_FRONTEND=noninteractive \
    ANSIBLE_VENV=/opt/ansible \
    PATH=/opt/ansible/bin:${PATH}

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        git \
        rsync \
        python3 \
        python3-pip \
        python3-venv \
        sudo \
    && rm -rf /var/lib/apt/lists/* \
    && python3 -m venv "${ANSIBLE_VENV}" \
    && "${ANSIBLE_VENV}/bin/pip" install --upgrade pip wheel

COPY requirements.txt /tmp/requirements.txt
COPY requirements.yml /tmp/requirements.yml
RUN "${ANSIBLE_VENV}/bin/pip" install -r /tmp/requirements.txt \
    && "${ANSIBLE_VENV}/bin/ansible-galaxy" collection install -r /tmp/requirements.yml \
    && rm /tmp/requirements.txt /tmp/requirements.yml

WORKDIR /workspace
CMD ["ansible", "--version"]
