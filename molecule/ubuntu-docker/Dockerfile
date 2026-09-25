FROM ubuntu:26.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && apt-get install -y --no-install-recommends python3 sudo ca-certificates curl \
    && rm -rf /var/lib/apt/lists/*
