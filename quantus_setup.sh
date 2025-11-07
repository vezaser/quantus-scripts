#!/usr/bin/env bash
set -euo pipefail

echo "=== Quantus Schrödinger Testnet - auto setup (node v0.2.10-matcha-shot + miner v0.2.1) ==="

read -rp "Podaj adres do nagród (qz...): " REWARDS
read -rp "Podaj nazwę noda (np. D01, WIN01): " NODE_NAME

if [[ -z "$REWARDS" || -z "$NODE_NAME" ]]; then
  echo "❌ Adres do nagród i nazwa noda nie mogą być puste."
  exit 1
fi

BASE_DIR="$HOME/quantus"
CHAIN_DIR="$BASE_DIR/chain_data_dir"

echo "📁 Czyścimy i tworzymy $BASE_DIR"
rm -rf "$BASE_DIR"
mkdir -p "$BASE_DIR"
cd "$BASE_DIR"

########################################
# 1️⃣ NODE  (v0.2.10-matcha-shot)
########################################

NODE_TGZ_URL="https://github.com/Quantus-Network/chain/releases/download/v0.2.10-matcha-shot/quantus-node-v0.2.10-matcha-shot-x86_64-unknown-linux-gnu.tar.gz"

echo "⬇️  Pobieram quantus-node (v0.2.10-matcha-shot)..."
curl -fsSL "$NODE_TGZ_URL" -o quantus-node.tar.gz
tar -xzf quantus-node.tar.gz
rm -f quantus-node.tar.gz

NODE_BIN=$(find . -maxdepth 2 -type f -name "quantus-node*" -perm -u+x | head -n1 || true)
if [[ -z "$NODE_BIN" ]]; then
  echo "❌  Nie znaleziono binarki quantus-node po rozpakowaniu."
  exit 1
fi

if [[ "$NODE_BIN" != "./quantus-node" ]]; then
  mv "$NODE_BIN" ./quantus-node
fi

chmod +x ./quantus-node
./quantus-node --version

########################################
# 2️⃣ MINER  (v0.2.1 - poprawny URL)
########################################

MINER_URL="https://github.com/Quantus-Network/quantus-miner/releases/download/v0.2.1/quantus-miner-linux-x86_64"

echo
echo "⬇️  Pobieram quantus-miner (v0.2.1, linux x86_64)..."
curl -fsSL "$MINER_URL" -o quantus-miner
chmod +x quantus-miner

./quantus-miner --help >/dev/null 2>&1 || { echo "❌ quantus-miner nie działa poprawnie"; exit 1; }
echo "✅ Miner OK"

########################################
# 3️⃣ NODE-KEY
########################################

echo
echo "🔑 Generuję node-key..."
./quantus-node key generate-node-key --file node-key
mkdir -p "$CHAIN_DIR"

########################################
# 4️⃣ SKRYPTY STARTOWE (wg wiki)
########################################

cat > run_node.sh <<EOF
#!/usr/bin/env bash
cd "$BASE_DIR"
RUST_LOG=info,sc_consensus_pow=debug ./quantus-node \\
  --max-blocks-per-request 64 \\
  --validator \\
  --chain schrodinger \\
  --sync full \\
  --node-key-file node-key \\
  --rewards-address $REWARDS \\
  --name "$NODE_NAME" \\
  --base-path $CHAIN_DIR
EOF

cat > run_miner.sh <<'EOF'
#!/usr/bin/env bash
cd "$(dirname "$0")"
RUST_LOG=info ./quantus-miner --workers 4 --engine cpu-montgomery
EOF

chmod +x run_node.sh run_miner.sh

echo
echo "✅ Instalacja zakończona."
echo "📂 Katalog: $BASE_DIR"
echo "   - quantus-node"
echo "   - quantus-miner"
echo "   - node-key"
echo "   - chain_data_dir/"
echo "   - run_node.sh"
echo "   - run_miner.sh"
echo
echo "▶️ Odpalaj w dwóch oknach / tmux:"
echo "   1️⃣ $BASE_DIR/run_miner.sh"
echo "   2️⃣ $BASE_DIR/run_node.sh"
echo
echo "Node: $NODE_NAME  | Rewards: $REWARDS"
