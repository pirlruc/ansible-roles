FROM ubuntu:26.04@sha256:da6fc2be547864451aa253836dd926da33623312df4a9a243e35dc877c378a78
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        python3=3.14.3-0ubuntu2 \
        sudo=1.9.17p2-1ubuntu3.1 \
        ca-certificates=20260601~26.04.1 \
        curl=8.18.0-1ubuntu2.7 \
    && rm -rf /var/lib/apt/lists/*
