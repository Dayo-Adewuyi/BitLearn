
const hre = require("hardhat");

async function main() {
  
  const DSCHOOLMarket = await hre.ethers.getContractFactory("DSCHOOLMarket");
  const dSCHOOLMarket = await DSCHOOLMarket.deploy();

  await dSCHOOLMarket.deployed();

  console.log("DSCHOOLMarket deployed to:", dSCHOOLMarket.address);

  const DSCHOOL = await hre.ethers.getContractFactory("DSCHOOL");
  const dSCHOOL = await DSCHOOL.deploy(dSCHOOLMarket.address);

  await dSCHOOL.deployed();

  console.log("DSCHOOL deployed to:", dSCHOOL.address);


}


main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
