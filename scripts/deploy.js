const hre = require("hardhat");

async function main() {
    const Exchange = await hre.ethers.getContractFactory("RarityExchange");
    const Market = await hre.ethers.getContractFactory("RarityMarket");


    // Burned Summoner
    // Proof:
    const owner = 496754;
    const rarity = "0xce761d788df608bd21bdd59d6f4b54b2e27f25bb";
    const gold = "0x2069B76Afe6b734Fb65D1d099E7ec64ee9CC76B2"

    const exchange = await Exchange.deploy(rarity, owner, gold)
    await exchange.deployed()
    const market = await Market.deploy(rarity, owner, gold)
    await market.deployed()

}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
