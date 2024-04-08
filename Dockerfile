FROM python:3.11.4-slim-bookworm as builder
LABEL maintainer "liebe_magi"

WORKDIR /work

# Install packages
RUN apt-get update && \
    apt-get install -y git curl build-essential nodejs npm --no-install-recommends

# Install online-judge-tools
RUN python -m pip install online-judge-tools

# Install atcoder-cli
RUN npm install -g atcoder-cli

# Install Python packages
COPY ./requirements_cpy.txt ./requirements.txt
RUN python -m pip install -r requirements.txt

# Install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# Install cargo-make
RUN cargo install --force cargo-make

FROM python:3.11.4-slim-bookworm as runner

COPY --from=builder /root/.cargo/bin/makers /usr/local/bin/makers
COPY --from=builder /usr/local/bin/oj /usr/local/bin/oj
COPY --from=builder /usr/local/bin/acc /usr/local/bin/acc

CMD ["/bin/bash"]