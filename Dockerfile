FROM debian:bookworm-slim

ARG UID=1001
ARG GID=1001

ARG DEBCONF_NOWARNINGS="yes"
ARG DEBIAN_FRONTEND noninteractive

RUN groupadd --gid ${GID} bitcoin \
  && useradd --create-home --no-log-init -u ${UID} -g ${GID} bitcoin \
  && apt-get update -y \
  && apt-get --no-install-recommends -y install jq curl gnupg gosu ca-certificates \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ARG TARGETPLATFORM

ARG BITCOIN_RC
ARG BITCOIN_VERSION
ARG BITCOIN_BASE=${BITCOIN_VERSION}${BITCOIN_RC}

ENV BITCOIN_DATA=/home/bitcoin/.bitcoin
ENV PATH=/opt/bitcoin-${BITCOIN_BASE}/bin:$PATH

LABEL org.opencontainers.image.title="Bitcoin Core"
LABEL org.opencontainers.image.description="Bitcoin Core docker image"

SHELL ["/bin/bash", "-c"]
RUN set -ex \
  && if [ -n "${BITCOIN_RC}" ]; then export SUBDIR=/test.; else export SUBDIR=; fi \
  && export URL="https://bitcoincore.org/bin/bitcoin-core-${BITCOIN_VERSION}${SUBDIR}${BITCOIN_RC}" \
  && if [ "${TARGETPLATFORM}" = "linux/amd64" ]; then export TARGETPLATFORM=x86_64-linux-gnu; fi \
  && if [ "${TARGETPLATFORM}" = "linux/arm64" ]; then export TARGETPLATFORM=aarch64-linux-gnu; fi \
  && if [ "${TARGETPLATFORM}" = "linux/arm/v7" ]; then export TARGETPLATFORM=arm-linux-gnueabihf; fi \
  && SIGNERS=($(curl -sS "https://api.github.com/repos/bitcoin-core/guix.sigs/contents/${BITCOIN_BASE}" | jq -r '.[] | select(.type=="dir") | .name' | tr "\n" " ")) \
  && for name in "${SIGNERS[@]}"; do \
  curl -sSL "https://raw.githubusercontent.com/bitcoin-core/guix.sigs/main/builder-keys/${name}.gpg" | gpg --import - ; \
  done \
  && curl -SLO "${URL}/bitcoin-${BITCOIN_BASE}-${TARGETPLATFORM}.tar.gz" \
  && curl -SLO "${URL}/SHA256SUMS" \
  && curl -SLO "${URL}/SHA256SUMS.asc" \
  && gpg --verify SHA256SUMS.asc SHA256SUMS \
  && grep " bitcoin-${BITCOIN_BASE}-${TARGETPLATFORM}.tar.gz" SHA256SUMS | sha256sum -c - \
  && tar -xzf ./*.tar.gz -C /opt \
  && rm ./*.tar.gz ./*.asc \
  && rm -rf "/opt/bitcoin-${BITCOIN_BASE}/bin/bitcoin-qt" \
  && rm -rf "/opt/bitcoin-${BITCOIN_BASE}/bin/test_bitcoin"
  
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

VOLUME ["/home/bitcoin/.bitcoin"]

# REST interface
EXPOSE 8080

# P2P network (mainnet, testnet & regnet respectively)
EXPOSE 8333 18333 18444

# RPC interface (mainnet, testnet & regnet respectively)
EXPOSE 8332 18332 18443

# ZMQ ports (for transactions & blocks respectively)
EXPOSE 28332 28333

ENTRYPOINT ["/entrypoint.sh"]

RUN bitcoind -version | grep "Bitcoin Core version v${BITCOIN_VERSION}"

CMD ["bitcoind"]
