#!/bin/bash
set -e

if [ -n "${PUID:-}" ] && [ "$PUID" != "0" ]; then
  usermod -u "$PUID" bitcoin
fi

if [ -n "${PGID:-}" ] && [ "$PGID" != "0" ]; then
  groupmod -g "$PGID" bitcoin
fi

[ "$#" -eq 0 ] && set -- bitcoind

case "${1:-}" in
  -*)
    set -- bitcoind "$@"
    ;;
esac

if [ "${1:-}" = "bitcoind" ]; then
  mkdir -p "$BITCOIN_DATA"
  chmod 700 "$BITCOIN_DATA"

  # Fix permissions for home dir.
  chown -R bitcoin:bitcoin "$(getent passwd bitcoin | cut -d: -f6)"

  # Fix permissions for bitcoin data dir.
  chown -R bitcoin:bitcoin "$BITCOIN_DATA"

  set -- "$@" -datadir="$BITCOIN_DATA"
fi

if [ "${1:-}" = "bitcoind" ] || [ "${1:-}" = "bitcoin-cli" ] || [ "${1:-}" = "bitcoin-tx" ]; then
  echo
  exec gosu bitcoin "$@"
fi

echo
exec "$@"
