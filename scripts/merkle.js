const { MerkleTree } = require("merkletreejs");
const keccak256 = require("keccak256");
const fs = require("fs");

const revoked = JSON.parse(fs.readFileSync("scripts/revoked.json"));
const leaves = revoked.map(x => keccak256(x));
const tree = new MerkleTree(leaves, keccak256, { sortPairs: true });
const root = tree.getHexRoot();

fs.writeFileSync("scripts/root.txt", root);
console.log("Merkle Root:", root);
