const { MerkleTree } = require("merkletreejs");
const keccak256 = require("keccak256");
const fs = require("fs");
const { ethers } = require("ethers");

(async () => {
  const doc = process.argv[2];
  const revoked = JSON.parse(fs.readFileSync("scripts/revoked.json"));
  const leaves = revoked.map(x => keccak256(x));
  const tree = new MerkleTree(leaves, keccak256, { sortPairs: true });

  const leaf = keccak256(doc);
  const proof = tree.getHexProof(leaf);

  const addresses = require("./contract_addresses.json");

  const provider = new ethers.JsonRpcProvider("http://127.0.0.1:8545");
  const contract = new ethers.Contract(
    addresses.education,
    ["function verify(bytes32 leaf, bytes32[] calldata proof) public view returns (bool)"],
    provider
  );

  const revokedOnChain = await contract.verify(leaf, proof);
  console.log(revokedOnChain ? "❌ REVOKED" : "✅ VALID");
})();
