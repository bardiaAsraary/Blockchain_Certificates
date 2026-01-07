async function main() {
  const IdentityRegistry = await ethers.getContractFactory("IdentityRegistry");
  const identity = await IdentityRegistry.deploy();
  await identity.waitForDeployment();
  const identityAddress = await identity.getAddress();

  console.log("IdentityRegistry:", identityAddress);

  const EducationVerification = await ethers.getContractFactory("EducationVerification");
  const edu = await EducationVerification.deploy();   // ⚠️ NO ARGUMENTS
  await edu.waitForDeployment();
  const eduAddress = await edu.getAddress();

  console.log("EducationVerification:", eduAddress);

  const fs = require("fs");
  fs.writeFileSync(
    "scripts/contract_addresses.json",
    JSON.stringify({
      identity: identityAddress,
      education: eduAddress
    }, null, 2)
  );
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
