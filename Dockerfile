FROM ubuntu:22.04
LABEL maintainer "liebe_magi"

ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NOWINTERACTIVE_SEEN true

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y git curl wget build-essential gdb lcov pkg-config software-properties-common gcc g++ make llvm \
    gfortran libopenblas-dev liblapack-dev libgeos-dev libssl-dev libffi-dev libgbm-dev libgdbm-compat-dev zlib1g-dev libbz2-dev libreadline6-dev \
    libsqlite3-dev libncurses5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev liblzma-dev lzma lzma-dev uuid-dev && \
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

# Set shell
SHELL ["/bin/bash", "-c"]
WORKDIR /tmp

# Install CPython 3.11.4
RUN wget https://www.python.org/ftp/python/3.11.4/Python-3.11.4.tar.xz -O Python-3.11.4.tar.xz && \
    tar xf Python-3.11.4.tar.xz && \
    cd Python-3.11.4 && \
    ./configure --enable-optimizations && \
    make && \
    make altinstall && \
    cd ..
# Install Python packages
RUN python3.11 -m pip install \
    poetry \
    poethepoet \
    online-judge-tools
# Install PyPy 3.10-v7.3.12
RUN wget https://downloads.python.org/pypy/pypy3.10-v7.3.12-linux64.tar.bz2 && \
    tar -xvf pypy3.10-v7.3.12-linux64.tar.bz2 && \
    ln -s /tmp/pypy3.10-v7.3.12-linux64/bin/pypy3 /usr/local/bin/pypy3.10 && \
    wget https://bootstrap.pypa.io/get-pip.py && \
    pypy3.10 get-pip.py

USER user
WORKDIR /home/user/atcoder
RUN mkdir -p /home/user/work_cpy && \
    mkdir -p /home/user/work_pypy
COPY --chown=${USER_ID}:${GROUP_ID} ./scripts/ ./scripts/
COPY --chown=${USER_ID}:${GROUP_ID} ./pyproject.toml ./
COPY --chown=${USER_ID}:${GROUP_ID} ./requirements_cpy.txt ../work_cpy/requirements.txt
COPY --chown=${USER_ID}:${GROUP_ID} ./requirements_pypy.txt ../work_pypy/requirements.txt
COPY --chown=${USER_ID}:${GROUP_ID} ./config.fish /home/user/.config/fish/config.fish

# Install asdf
RUN git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.13.1 && \
    source $HOME/.asdf/asdf.sh && \
    # Install Node.js
    asdf plugin-add nodejs && \
    asdf install nodejs 18.17.1 && \
    asdf global nodejs 18.17.1 && \
    # Install atcoder-cli
    npm install -g atcoder-cli && \
    ln -s /usr/local/bin/oj /home/user/.asdf/shims/oj

# Poetry configuration
RUN poetry config virtualenvs.in-project true

# Install Python packages for CPython
WORKDIR /home/user/work_cpy
RUN ln -s /home/user/atcoder/pyproject.toml && \
    poetry install && \
    poetry run python -m pip install -r requirements.txt

# Install Python packages for PyPy
WORKDIR /home/user/work_pypy
RUN ln -s /home/user/atcoder/pyproject.toml && \
    poetry install && \
    poetry env use /usr/local/bin/pypy3.10 && \
    poetry run python -m pip install -r requirements.txt

WORKDIR /home/user/atcoder
RUN ln -s /home/user/work_cpy/.venv

CMD ["/usr/bin/fish"]