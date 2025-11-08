#!/usr/bin/env bash
set -euo pipefail
cd /root/quantus
exec ./quantus-node \
  --validator \
  --chain schrodinger \
  --sync full \
  --base-path /root/quantus/chain_data_dir \
  --node-key-file /root/quantus/node-key \
  --rewards-address qzobRvuvMF8LDFwDa7ZuizaviNmVQNtGdQ6idq8jkFxt8tshy \
  --name D02 \
  --external-miner-url "http://127.0.0.1:9833" \
  --prometheus-port 9616 \
  --rpc-port 9944
