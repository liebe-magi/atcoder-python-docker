# atcoder-python-docker

AtCoder用Python Docker環境

## Features

- 2023年の[新ジャッジ環境](https://img.atcoder.jp/file/language-update/language-list.html)を構築
- [atcoder-cli](https://github.com/Tatamo/atcoder-cli)と[oj](https://github.com/online-judge-tools/oj)を用いた解答用ファイル生成、ローカルでのテストケースチェック、提出
- [poethepoet](https://github.com/nat-n/poethepoet)による共通化されたコマンドの提供

## Installation

### Install from DockerHub

```
docker pull liebemagi/atcoder-python:latest
```

### Build

```
git clone https://github.com/liebe-magi/atcoder-python-docker
cd atcoder-python-docker
docker build . -t atcoder-python
```

## Usage

- VSCodeでのDevContainer環境は[こちら](https://github.com/liebe-magi/atcoder-python-template)