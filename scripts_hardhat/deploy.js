const fs = require("fs");

async function main() {
  const EducationVerification = await ethers.getContractFactory("EducationVerification");
  const education = await EducationVerification.deploy(); // ❗ بدون آرگومان
  await education.waitForDeployment();

  const deployed = {
    EducationVerification: education.target
  };

  fs.writeFileSync(
    "deployed.json",
    JSON.stringify(deployed, null, 2)
  );

  console.log("EducationVerification:", education.target);
  console.log("Saved to deployed.json");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
