# syntax=docker/dockerfile:1

FROM debian:trixie-slim

ARG UID=1001
ARG GID=1001

ARG DEBCONF_NOWARNINGS="yes"
ARG DEBIAN_FRONTEND="noninteractive"
ARG DEBCONF_NONINTERACTIVE_SEEN="true"

RUN <<EOF
  set -eu

  # Create bitcoin user
  groupadd --gid ${GID} bitcoin
  useradd --create-home --no-log-init -u ${UID} -g ${GID} bitcoin

  apt-get update -y
  apt-get --no-install-recommends -y install \
    jq \
    curl \
    gnupg \
    gosu \
    iputils-ping \
    ca-certificates

  apt-get clean
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
EOF

ARG TARGETPLATFORM

ARG BITCOIN_RC
ARG BITCOIN_VERSION
ARG BITCOIN_BASE=${BITCOIN_VERSION}${BITCOIN_RC}

ENV BITCOIN_DATA=/home/bitcoin/.bitcoin
ENV PATH=/opt/bitcoin-${BITCOIN_BASE}/bin:$PATH

SHELL ["/bin/bash", "-c"]

RUN <<EOF
  set -eux

  # Determine Bitcoin Core release URL
  if [ -n "${BITCOIN_RC}" ]; then
    export SUBDIR=/test.
  else
    export SUBDIR=
  fi

  export URL="https://bitcoincore.org/bin/bitcoin-core-${BITCOIN_VERSION}${SUBDIR}${BITCOIN_RC}"

  # Map Docker platform to Bitcoin Core archive platform
  if [ "${TARGETPLATFORM}" = "linux/amd64" ]; then
    export TARGETPLATFORM=x86_64-linux-gnu
  fi

  if [ "${TARGETPLATFORM}" = "linux/arm64" ]; then
    export TARGETPLATFORM=aarch64-linux-gnu
  fi

  if [ "${TARGETPLATFORM}" = "linux/arm/v7" ]; then
    export TARGETPLATFORM=arm-linux-gnueabihf
  fi

  # Import Bitcoin Core Guix signer keys
  SIGNERS=($(curl -sS "https://api.github.com/repos/bitcoin-core/guix.sigs/contents/${BITCOIN_BASE}" | jq -r '.[] | select(.type=="dir") | .name' | tr "\n" " "))

  for name in "${SIGNERS[@]}"; do
    curl -sSL "https://raw.githubusercontent.com/bitcoin-core/guix.sigs/main/builder-keys/${name}.gpg" | gpg --import -
  done

  # Download Bitcoin Core release files
  curl -SLO "${URL}/bitcoin-${BITCOIN_BASE}-${TARGETPLATFORM}.tar.gz"
  curl -SLO "${URL}/SHA256SUMS"
  curl -SLO "${URL}/SHA256SUMS.asc"

  # Verify Bitcoin Core release
  gpg --verify SHA256SUMS.asc SHA256SUMS
  grep " bitcoin-${BITCOIN_BASE}-${TARGETPLATFORM}.tar.gz" SHA256SUMS | sha256sum -c -

  # Install Bitcoin Core
  tar -xzf ./*.tar.gz -C /opt

  # Cleanup
  rm ./*.tar.gz ./*.asc
  rm -rf "/opt/bitcoin-${BITCOIN_BASE}/bin/bitcoin-qt"
  rm -rf "/opt/bitcoin-${BITCOIN_BASE}/bin/test_bitcoin"
EOF

COPY --chmod=755 entrypoint.sh /entrypoint.sh

VOLUME ["/home/bitcoin/.bitcoin"]

# REST interface
EXPOSE 8080

# P2P network (mainnet, testnet & regnet respectively)
EXPOSE 8333 18333 18444

# RPC interface (mainnet, testnet & regnet respectively)
EXPOSE 8332 18332 18443

# ZMQ ports (for transactions & blocks respectively)
EXPOSE 28332 28333

HEALTHCHECK --interval=300s --start-period=60s --start-interval=10s --timeout=20s CMD gosu bitcoin bitcoin-cli -rpcwait -getinfo || exit 1

ENTRYPOINT ["/entrypoint.sh"]

RUN bitcoind -version | grep "version v${BITCOIN_VERSION}"

CMD ["bitcoind"]
