# Python
FROM python:3.11.4-slim-bookworm as python

WORKDIR /work

# Install packages
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y git build-essential --no-install-recommends

# Install online-judge-tools
RUN python -m pip install online-judge-tools

# Install Python packages
COPY ./requirements.txt ./requirements.txt
RUN python -m pip install -r requirements.txt

# Node.js
FROM node:bookworm-slim as node

# Install atcoder-cli
RUN npm install -g atcoder-cli

# Rust
FROM rust:bookworm as rust

# Install packages
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y git build-essential cmake --no-install-recommends

# Install cargo-make
RUN cargo install --force cargo-make
RUN cargo install starship --locked

# Build fish
# RUN git clone https://github.com/fish-shell/fish-shell.git -b 3.7.1 && \
#     cd fish-shell && \
#     mkdir build && \
#     cd build && \
#     cmake .. && \
#     make && \
#     make install

# Runner
FROM python:3.11.4-slim-bookworm as runner
LABEL maintainer "liebe_magi"

# Copy from Python
COPY --from=python /usr/local/bin/oj /usr/local/bin/oj
COPY --from=python /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages

# Copy from Node.js
COPY --from=node /usr/local/bin /usr/local/bin
COPY --from=node /usr/local/lib/node_modules /usr/local/lib/node_modules
COPY --from=node /usr/local/include /usr/local/include
COPY --from=node /usr/local/share /usr/local/share
COPY --from=node /usr/local/lib /usr/local/lib

# # Copy from Rust
COPY --from=rust /usr/local/cargo/bin/makers /usr/local/bin/makers
COPY --from=rust /usr/local/cargo/bin/starship /usr/local/bin/starship
# COPY --from=rust /usr/local/bin/fish /usr/local/bin/fish

# Install fish
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y build-essential cmake libpcre2-dev gettext software-properties-common --no-install-recommends && \
    apt-add-repository ppa:fish-shell/release-3 && \
    apt-get update && \
    apt-get install -y fish --no-install-recommends

# Create a non-root user
ARG USER_ID=1000 GROUP_ID=1000
RUN groupadd -g ${GROUP_ID} user && \
    useradd -m --no-log-init --system --uid ${USER_ID} user -g user -G sudo -s /usr/bin/fish && \
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Change the user
USER user
WORKDIR /home/user/work

CMD ["/bin/bash"]