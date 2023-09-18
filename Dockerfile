FROM ubuntu:22.04
LABEL maintainer "liebe_magi"

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y git curl wget build-essential pkg-config software-properties-common gcc make llvm
RUN apt-get install -y libgeos-dev libssl-dev libffi-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev libncurses5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev liblzma-dev

# Install fish
RUN apt-add-repository ppa:fish-shell/release-3
RUN apt update
RUN apt install -y fish

# Install starship
RUN curl -sS https://raw.githubusercontent.com/liebe-magi/starship/master/install/install.sh | sh

# create a non-root user
ARG USER_ID=1000
ARG GROUP_ID=1000
RUN groupadd -g ${GROUP_ID} user
RUN useradd -m --no-log-init --system --uid ${USER_ID} user -g user -G sudo -s /usr/bin/fish
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
USER user
WORKDIR /home/user

# set shell
SHELL ["/bin/bash", "-c"]

# Install asdf
RUN git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.13.1

# Install Python
RUN source $HOME/.asdf/asdf.sh && \
    asdf plugin-add python && \
    asdf install python 3.11.4 && \
    asdf install python pypy3.10-7.3.12 && \
    asdf global python 3.11.4

# Install Poetry
RUN source $HOME/.asdf/asdf.sh && \
    asdf plugin-add poetry && \
    asdf install poetry latest && \
    asdf global poetry latest

# Install Node.js
RUN source $HOME/.asdf/asdf.sh && \
    asdf plugin-add nodejs && \
    asdf install nodejs 18.17.1 && \
    asdf global nodejs 18.17.1

# Install poethepoet
RUN source $HOME/.asdf/asdf.sh && \
    pip install poethepoet

# Install atcoder-cli
RUN source $HOME/.asdf/asdf.sh && \
    npm install -g atcoder-cli

# Install online-judge-tools
RUN source $HOME/.asdf/asdf.sh && \
    pip install online-judge-tools

# Install python dependencies
WORKDIR /home/user/atcoder
COPY pyproject.toml .
COPY poetry.lock .
COPY scripts/ ./scripts/
RUN source $HOME/.asdf/asdf.sh && \
    poetry install

# Copy dotfiles
COPY config.fish /home/user/.config/fish/config.fish

# Change permission
USER root
RUN chown -R 1000:1000 /home/user
USER user

CMD ["/usr/bin/fish"]