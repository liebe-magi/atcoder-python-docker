FROM ubuntu:22.04

RUN apt-get update
RUN apt-get install -y wget bzip2 curl git build-essential gfortran cmake pkg-config libopenblas-dev libgeos-dev

WORKDIR /work

# Install pypy3.10-v7.3.12
RUN wget https://downloads.python.org/pypy/pypy3.10-v7.3.12-linux64.tar.bz2
RUN tar -jxvf pypy3.10-v7.3.12-linux64.tar.bz2
RUN rm -rf pypy3.10-v7.3.12-linux64.tar.bz2
ENV PATH $PATH:/work/pypy3.10-v7.3.12-linux64/bin

# Install pip
RUN curl -O https://bootstrap.pypa.io/get-pip.py
RUN pypy get-pip.py
RUN rm get-pip.py

# Install dependencies
COPY requirements.txt .
RUN pip install -r requirements.txt
RUN rm requirements.txt
RUN pip install git+https://github.com/not522/ac-library-python

CMD ["/bin/bash"]