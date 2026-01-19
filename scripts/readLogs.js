const fs = require("fs");
const { ethers } = require("ethers");

async function main() {
  const certId = process.argv[2];
  if (!certId) {
    console.log("Usage: node readLogs.js <CERT_ID>");
    return;
  }

  const deployed = JSON.parse(fs.readFileSync("deployed.json"));
  const provider = new ethers.JsonRpcProvider("http://127.0.0.1:8545");

  const abi = [
    "event CertificateIssued(bytes32 indexed certHash, uint256 timestamp)",
    "event CertificateRevoked(bytes32 indexed certHash, uint256 timestamp)"
  ];

  const contract = new ethers.Contract(
    deployed.EducationVerification,
    abi,
    provider
  );

  const certHash = ethers.keccak256(
    ethers.toUtf8Bytes(certId)
  );

  console.log("CERT ID:", certId);
  console.log("CERT HASH:", certHash);
  console.log("────────────────────────────");

  // Issued events
  const issuedEvents = await contract.queryFilter(
    contract.filters.CertificateIssued(certHash)
  );

  for (const e of issuedEvents) {
    const block = await provider.getBlock(e.blockNumber);
    console.log("🟢 ISSUED");
    console.log(" Block:", e.blockNumber);
    console.log(" Time :", new Date(block.timestamp * 1000));
    console.log(" Tx   :", e.transactionHash);
    console.log("");
  }

  // Revoked events
  const revokedEvents = await contract.queryFilter(
    contract.filters.CertificateRevoked(certHash)
  );

  for (const e of revokedEvents) {
    const block = await provider.getBlock(e.blockNumber);
    console.log("🔴 REVOKED");
    console.log(" Block:", e.blockNumber);
    console.log(" Time :", new Date(block.timestamp * 1000));
    console.log(" Tx   :", e.transactionHash);
    console.log("");
  }
}

main();
