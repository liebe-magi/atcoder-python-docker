# Python
FROM python:3.11.4-slim-bookworm as python

ARG TARGETARCH

# Install packages
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y git build-essential libgmp-dev libmpfr-dev libmpc-dev --no-install-recommends

# Install online-judge-tools
RUN python -m pip install --upgrade pip && \
    python -m pip install online-judge-tools

# Install Python packages
COPY ./docker_cpython/requirements_${TARGETARCH}.txt ./requirements.txt
RUN python -m pip install -r requirements.txt

# Node.js
FROM node:18.20.1-bookworm-slim as node

# Install tools & libraries for AtCoder
RUN npm install -g atcoder-cli

# Runner
FROM pypy:3.10-7.3.12-slim-bookworm as runner
LABEL maintainer "liebe_magi"

ARG TARGETARCH
WORKDIR /work

# Copy from Python
COPY --from=python /usr/local/include /usr/local/include
COPY --from=python /usr/local/lib /usr/local/lib
COPY --from=python /usr/local/bin /usr/local/bin

# Copy from Node.js
COPY --from=node /usr/local/include /usr/local/include
COPY --from=node /usr/local/lib /usr/local/lib
COPY --from=node /usr/local/bin /usr/local/bin

COPY ./scripts ./scripts

# Install packages
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y git build-essential gfortran pkg-config cmake time \
    libopenblas-dev libgeos-dev curl ca-certificates fish silversearcher-ag --no-install-recommends && \
    curl -sS https://starship.rs/install.sh | sh -s -- --yes && \
    apt-get autoremove && \
    apt-get autoclean && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Python packages
COPY ./docker_pypy/requirements_${TARGETARCH}.txt ./requirements.txt
RUN python -m pip install --upgrade pip && \
    python -m pip install -r requirements.txt && \
    rm requirements.txt

# Create a non-root user
ARG USER_ID=1000 GROUP_ID=1000
RUN groupadd -g ${GROUP_ID} user && \
    useradd -m --no-log-init --system --uid ${USER_ID} user -g user -G sudo -s /usr/bin/fish && \
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Change the user
USER user
WORKDIR /home/user/work

COPY --chown=${USER_ID}:${GROUP_ID} ./config.fish /home/user/.config/fish/config.fish

CMD ["/usr/bin/fish"]