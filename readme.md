<h1 align="center">Bitcoin Core<br />
<div align="center">
<a href="https://github.com/dobtc/bitcoin"><img src="https://raw.githubusercontent.com/dobtc/bitcoin/master/.github/logo.png" title="Logo" style="max-width:100%;" width="128" /></a>
</div>
<div align="center">

[![Build]][build_url]
[![Version]][tag_url]
[![Size]][tag_url]
[![Package]][pkg_url]
[![Pulls]][hub_url]

</div></h1>

Docker container for running a Bitcoin Core full node.

## Features ✨

- Runs a Bitcoin Core full node
- Supports amd64 and arm64 platforms
- Exposes the JSON-RPC and peer-to-peer ports
- Supports custom `bitcoin.conf` configuration
- Includes `bitcoin-cli` for node management

## Usage  🐳

##### Docker Compose:

```yaml
services:
  bitcoin:
    image: dobtc/bitcoin
    container_name: bitcoin
    ports:
      - 8332:8332
      - 8333:8333
    volumes:
      - ./bitcoin:/home/bitcoin/.bitcoin
    restart: always
    stop_grace_period: 1m
```

##### Docker CLI:

```bash
docker run -it --rm --name bitcoin -v "${PWD:-.}/bitcoin:/home/bitcoin/.bitcoin" docker.io/dobtc/bitcoin -printtoconsole
```

##### Executing `getinfo` on the running container:

```bash
docker exec --user bitcoin bitcoin bitcoin-cli -getinfo
```

## Stars 🌟
[![Stargazers](https://raw.githubusercontent.com/star-stats/stars/refs/heads/data/charts/dobtc-bitcoin.svg)](https://github.com/dobtc/bitcoin/stargazers)

[build_url]: https://github.com/dobtc/bitcoin/
[hub_url]: https://hub.docker.com/r/dobtc/bitcoin
[tag_url]: https://hub.docker.com/r/dobtc/bitcoin/tags
[pkg_url]: https://github.com/dobtc/bitcoin/pkgs/container/bitcoin

[Build]: https://github.com/dobtc/bitcoin/actions/workflows/build.yml/badge.svg
[Size]: https://img.shields.io/docker/image-size/dobtc/bitcoin/latest?color=066da5&label=size
[Pulls]: https://img.shields.io/docker/pulls/dobtc/bitcoin.svg?style=flat&label=pulls&logo=docker
[Version]: https://img.shields.io/docker/v/dobtc/bitcoin/latest?arch=amd64&sort=semver&color=066da5
[Package]: https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fipitio.github.io%2Fbackage%2Fdobtc%2Fbitcoin%2Fbitcoin.json&query=%24.downloads&logo=github&style=flat&color=066da5&label=pulls
