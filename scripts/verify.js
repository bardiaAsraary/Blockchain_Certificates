const fs = require("fs");
const { ethers } = require("ethers");

async function main() {
  const certId = process.argv[2];
  if (!certId) {
    console.log("Usage: node verify.js <CERT_ID>");
    return;
  }

  const deployed = JSON.parse(fs.readFileSync("deployed.json"));
  const provider = new ethers.JsonRpcProvider("http://127.0.0.1:8545");

  const abi = [
    "function verifyCertificate(string memory) view returns (bool issued, bool revoked, uint256 issuedAt, uint256 revokedAt)"
  ];

  const contract = new ethers.Contract(
    deployed.EducationVerification,
    abi,
    provider
  );

  const result = await contract.verifyCertificate(certId);

  console.log("Issued:", result[0]);
  console.log("Revoked:", result[1]);
  console.log("Issued At:", result[2].toString());
  console.log("Revoked At:", result[3].toString());
}

main();
