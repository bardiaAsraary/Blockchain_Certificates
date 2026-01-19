const fs = require("fs");
const { ethers } = require("ethers");

async function main() {
  const certId = process.argv[2];
  if (!certId) throw "Usage: node revoke.js <CERT_ID>";

  const deployed = JSON.parse(fs.readFileSync("deployed.json"));
  const provider = new ethers.JsonRpcProvider("http://127.0.0.1:8545");

  const signer = await provider.getSigner(0);

  const abi = [
    "function revokeCertificate(string)"
  ];

  const contract = new ethers.Contract(
    deployed.EducationVerification,
    abi,
    signer
  );

  const tx = await contract.revokeCertificate(certId);
  await tx.wait();

  console.log("🚫 Revoked:", certId);
}

main();
