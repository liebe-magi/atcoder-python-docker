FROM ubuntu:22.04
LABEL maintainer "liebe_magi"

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y git curl wget build-essential pkg-config software-properties-common gcc make llvm \
    libgeos-dev libssl-dev libffi-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev libncurses5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev liblzma-dev && \
    # Install fish
    apt-add-repository ppa:fish-shell/release-3 && \
    apt-get update && \
    apt-get install -y fish && \
    apt-get clean && \
    apt-get autoremove && \
    rm -rf /var/lib/apt/lists/* && \
    # Install starship
    curl -sS https://raw.githubusercontent.com/liebe-magi/starship/master/install/install.sh | sh

# Create a non-root user
ARG USER_ID=1000 GROUP_ID=1000
RUN groupadd -g ${GROUP_ID} user && \
    useradd -m --no-log-init --system --uid ${USER_ID} user -g user -G sudo -s /usr/bin/fish && \
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
USER user
WORKDIR /home/user/atcoder
COPY --chown=${USER_ID}:${GROUP_ID} pyproject.toml poetry.lock ./
COPY --chown=${USER_ID}:${GROUP_ID} scripts/ ./scripts/
COPY --chown=${USER_ID}:${GROUP_ID} config.fish /home/user/.config/fish/config.fish

# Set shell
SHELL ["/bin/bash", "-c"]

# Install asdf
RUN git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.13.1 && \
    source $HOME/.asdf/asdf.sh && \
    # Install Python
    asdf plugin-add python && \
    asdf install python 3.11.4 && \
    asdf install python pypy3.10-7.3.12 && \
    asdf global python 3.11.4 && \
    # Install Poetry
    asdf plugin-add poetry && \
    asdf install poetry latest && \
    asdf global poetry latest && \
    # Install Node.js
    asdf plugin-add nodejs && \
    asdf install nodejs 18.17.1 && \
    asdf global nodejs 18.17.1 && \
    # Install poethepoet
    pip install poethepoet && \
    # Install atcoder-cli
    npm install -g atcoder-cli && \
    # Install online-judge-tools
    pip install online-judge-tools && \
    # Install python dependencies
    poetry install

CMD ["/usr/bin/fish"]