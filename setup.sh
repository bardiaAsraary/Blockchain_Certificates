#!/bin/bash
set -e

echo "=============================="
echo " Revocation Blockchain Setup "
echo "=============================="

PROJECT_DIR="/home/user/revocation"
cd "$PROJECT_DIR"

echo "[1] Cleaning previous state..."
pkill -f hardhat || true
rm -rf node_modules package-lock.json artifacts cache

echo "[2] Initializing npm project..."
npm init -y >/dev/null

echo "[3] Installing dependencies..."
npm install --save-dev hardhat @nomicfoundation/hardhat-toolbox ethers
npm install merkletreejs keccak256

echo "[4] Creating Hardhat structure..."
mkdir -p contracts scripts_hardhat scripts

echo "[5] Moving Solidity contracts..."
mv -f *.sol contracts/ || true

echo "[6] Writing Hardhat config..."
cat <<EOF > hardhat.config.js
require("@nomicfoundation/hardhat-toolbox");

module.exports = {
  solidity: "0.8.19",
  networks: {
    localhost: {
      url: "http://127.0.0.1:8545"
    }
  }
};
EOF

echo "[7] Writing deploy script..."
cat <<EOF > scripts_hardhat/deploy.js
async function main() {
  const IdentityRegistry = await ethers.getContractFactory("IdentityRegistry");
  const identity = await IdentityRegistry.deploy();
  await identity.deployed();
  console.log("IdentityRegistry:", identity.address);

  const EducationVerification = await ethers.getContractFactory("EducationVerification");
  const edu = await EducationVerification.deploy(identity.address);
  await edu.deployed();
  console.log("EducationVerification:", edu.address);

  require('fs').writeFileSync(
    "scripts/contract_addresses.json",
    JSON.stringify({
      identity: identity.address,
      education: edu.address
    }, null, 2)
  );
}

main().catch(err => {
  console.error(err);
  process.exit(1);
});
EOF

echo "[8] Writing Merkle generator..."
cat <<EOF > scripts/merkle.js
const { MerkleTree } = require("merkletreejs");
const keccak256 = require("keccak256");
const fs = require("fs");

const revoked = JSON.parse(fs.readFileSync("scripts/revoked.json"));
const leaves = revoked.map(x => keccak256(x));
const tree = new MerkleTree(leaves, keccak256, { sortPairs: true });
const root = tree.getHexRoot();

fs.writeFileSync("scripts/root.txt", root);
console.log("Merkle Root:", root);
EOF

echo "[9] Writing revoke script..."
cat <<EOF > scripts/revoke.js
const fs = require("fs");
const { ethers } = require("ethers");

const root = fs.readFileSync("scripts/root.txt", "utf8");
const addresses = require("./contract_addresses.json");

const provider = new ethers.providers.JsonRpcProvider("http://127.0.0.1:8545");
const signer = provider.getSigner(0);

const abi = [
  "function setRevocationRoot(bytes32 root) public"
];

(async () => {
  const contract = new ethers.Contract(addresses.education, abi, signer);
  const tx = await contract.setRevocationRoot(root);
  await tx.wait();
  console.log("Root anchored on-chain");
})();
EOF

echo "[10] Writing verify script..."
cat <<EOF > scripts/verify.js
const { MerkleTree } = require("merkletreejs");
const keccak256 = require("keccak256");
const fs = require("fs");
const { ethers } = require("ethers");

const doc = process.argv[2];
const revoked = JSON.parse(fs.readFileSync("scripts/revoked.json"));
const leaves = revoked.map(x => keccak256(x));
const tree = new MerkleTree(leaves, keccak256, { sortPairs: true });

const leaf = keccak256(doc);
const proof = tree.getHexProof(leaf);
const addresses = require("./contract_addresses.json");

const provider = new ethers.providers.JsonRpcProvider("http://127.0.0.1:8545");
const contract = new ethers.Contract(
  addresses.education,
  ["function verify(bytes32 leaf, bytes32[] calldata proof) public view returns (bool)"],
  provider
);

(async () => {
  const revoked = await contract.verify(leaf, proof);
  console.log(revoked ? "❌ REVOKED" : "✅ VALID");
})();
EOF

echo "[11] Writing revoked list..."
echo '["ALIDXT-MSC-2025"]' > scripts/revoked.json

echo "[12] Compiling contracts..."
npx hardhat compile

echo "[13] Starting Hardhat node..."
npx hardhat node >/tmp/hardhat.log 2>&1 &
sleep 5

echo "[14] Deploying contracts..."
npx hardhat run scripts_hardhat/deploy.js --network localhost

echo "[15] Generating Merkle root..."
node scripts/merkle.js

echo "[16] Anchoring root..."
node scripts/revoke.js

echo "[17] Verifying document..."
node scripts/verify.js ALIDXT-MSC-2025

echo "=============================="
echo " ✅ SYSTEM READY FOR DEMO "
echo "=============================="
