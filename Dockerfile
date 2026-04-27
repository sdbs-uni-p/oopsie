# Use a stable base image
FROM ubuntu:22.04

# Avoid interactive prompts during build
ENV DEBIAN_FRONTEND=noninteractive

# OpenNMS workaround:
# Tell Yarn to bypass strict Node.js version checks
ENV YARN_IGNORE_ENGINES=1

# Install common dependencies, Docker Client, and git
RUN apt-get update && apt-get install -y \
    curl \
    time \
    git \
    maven \
    gnupg \
    ca-certificates \
    lsb-release \
    bzip2 \
    build-essential \
    # Docker Client (so we can run 'docker compose' from inside)
    && mkdir -p /etc/apt/keyrings \
    && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null \
    && apt-get update && apt-get install -y docker-ce-cli docker-compose-plugin
    
# Install Java versions
RUN apt-get install -y openjdk-17-jdk openjdk-8-jdk

# Python dependencies for experiment scripts
RUN pip3 install pandas

# Workaround for OpenNMS: Perl script `ulimit` to be in PATH
RUN echo '#!/bin/bash' > /usr/local/bin/ulimit && \
    echo 'builtin ulimit "$@"' >> /usr/local/bin/ulimit && \
    chmod +x /usr/local/bin/ulimit

# Copy artifact files
WORKDIR /artifact
COPY . /artifact

WORKDIR /artifact

# Make scripts executable
RUN chmod +x scripts/*.py
RUN chmod +x scripts/*.sh

