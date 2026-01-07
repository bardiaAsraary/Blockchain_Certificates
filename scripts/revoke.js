const fs = require("fs");
const { ethers } = require("ethers");

(async () => {
  const root = fs.readFileSync("scripts/root.txt", "utf8").trim();
  const addresses = require("./contract_addresses.json");

  const provider = new ethers.JsonRpcProvider("http://127.0.0.1:8545");
  const signer = await provider.getSigner();

  const abi = [
    "function revokeCertificate(bytes32 newRoot) external"
  ];

  const contract = new ethers.Contract(addresses.education, abi, signer);

  const tx = await contract.revokeCertificate(root);
  await tx.wait();

  console.log("✅ Merkle root successfully revoked on-chain");
})();
