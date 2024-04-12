[![Docker Pulls](https://img.shields.io/docker/pulls/liebemagi/atcoder-python)](https://hub.docker.com/r/liebemagi/atcoder-python)

# atcoder-python-docker

AtCoder用Python Docker環境

## Features

- 2023年の[新ジャッジ環境](https://img.atcoder.jp/file/language-update/language-list.html)を構築
- [atcoder-cli](https://github.com/Tatamo/atcoder-cli)と[oj](https://github.com/online-judge-tools/oj)を用いた解答用ファイル生成、ローカルでのテストケースチェック、提出
- 独自コマンド(`atc`)による共通化されたコマンドの提供

## Installation

### Install from DockerHub

#### CPython
```
docker pull liebemagi/atcoder-python:latest
```

#### PyPy
```
docker pull liebemagi/atcoder-python:latest-pypy
```

### Build

```
git clone https://github.com/liebe-magi/atcoder-python-docker
cd atcoder-python-docker

# CPython
docker build -t atcoder-python -f docker_cpython/Dockerfile .

# PyPy
docker build -t atcoder-python -f docker_pypy/Dockerfile .
```

## Usage

- VSCodeでのDevContainer環境は[こちら](https://github.com/liebe-magi/atcoder-python-template)

### Usage for `atc` command

#### Generate `main.py` & get test case

```
atc new abc001
```

#### Run test

```
atc run abc001-a
```
#### Submit a code

```
atc run abc001-a --submit

# -sでも可
atc run abc001-a -s

# PyPyで提出する場合
atc run abc001-a -s --pypy
```
