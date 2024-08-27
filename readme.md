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

A docker image of Bitcoin Core with support for the following platforms:

* `amd64` (x86_64)
* `arm32v7` (armv7)
* `arm64` (aarch64, armv8)

## Usage  🐳

Via Docker Compose:

```yaml
services:
  bitcoin:
    container_name: bitcoin
    image: dobtc/bitcoin
    ports:
      - 8332:8332
      - 8333:8333
    volumes:
      - /opt/bitcoin:/home/bitcoin/.bitcoin
```

Via Docker CLI:

```bash
docker run -it --rm dobtc/bitcoin -printtoconsole
```

Executing `getinfo` on the running container:

```bash
docker exec --user bitcoin bitcoin bitcoin-cli -getinfo
```

## Stars 🌟
[![Stars](https://starchart.cc/dobtc/bitcoin.svg?variant=adaptive)](https://starchart.cc/dobtc/bitcoin)

[build_url]: https://github.com/dobtc/bitcoin/
[hub_url]: https://hub.docker.com/r/dobtc/bitcoin
[tag_url]: https://hub.docker.com/r/dobtc/bitcoin/tags
[pkg_url]: https://github.com/dobtc/bitcoin/pkgs/container/bitcoin

[Build]: https://github.com/dobtc/bitcoin/actions/workflows/build.yml/badge.svg
[Size]: https://img.shields.io/docker/image-size/dobtc/bitcoin/latest?color=066da5&label=size
[Pulls]: https://img.shields.io/docker/pulls/dobtc/bitcoin.svg?style=flat&label=pulls&logo=docker
[Version]: https://img.shields.io/docker/v/dobtc/bitcoin/latest?arch=amd64&sort=semver&color=066da5
[Package]: 
https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fipitio.github.io%2Fbackage%2Fdobtc%2Fbitcoin%2Fbitcoin.json&query=%24.downloads&logo=github&style=flat&color=066da5&label=pulls
