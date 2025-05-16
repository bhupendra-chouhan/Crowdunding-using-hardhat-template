const hre = require("hardhat");

async function main() {
  console.log("Deploying StudentReportCard contract...");

  // Deploy the contract
  const StudentReportCard = await hre.ethers.getContractFactory("StudentReportCard");
  const reportCard = await StudentReportCard.deploy();

  await reportCard.deployed();

  console.log(`StudentReportCard deployed to ${reportCard.address} on Core Testnet 2`);
  
  // Verify contract on block explorer (if API is available)
  console.log("Waiting for block confirmations...");
  await reportCard.deployTransaction.wait(5); // Wait for 5 blocks for better confirmation
  
  console.log("Contract deployment completed successfully!");
}

// Execute the deployment
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
