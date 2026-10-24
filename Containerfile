FROM debian:trixie-20261020-slim
ARG NODE_VERSION=24.x

# Prevent apt from interactive questions
ENV DEBIAN_FRONTEND=noninteractive

# Allow pi to output colored text, which is disabled in docker by default
ENV TERM=xterm-256color 

# Install recommended tools for pi coding agent fast search, etc.
RUN apt-get update && apt-get install -y --no-install-recommends \
  ca-certificates \
  curl \
  gnupg \
  git \
  ripgrep \
  tar \
  unzip \
  fd-find \
  vim \
  htop \
  && mkdir -p /etc/apt/keyrings \
  && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key \
  | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
  && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_${NODE_VERSION} nodistro main" | tee /etc/apt/sources.list.d/nodesource.list

# Cleanup apt cache to keep the image size small
RUN apt-get update && apt-get install -y --no-install-recommends \
  nodejs \
  && rm -rf /var/lib/apt/lists/* \
  && apt-get clean

# Install Pi Coding Agent
RUN npm install -g --ignore-scripts @earendil-works/pi-coding-agent

# Target folder for Pi Coding Agent where user volume is mounted
WORKDIR /workspace

# Let the containerized Pi Coding Agent be usable like the cli tool that it is
ENTRYPOINT ["pi"]

