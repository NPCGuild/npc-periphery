require("dotenv").config()
require("@nomiclabs/hardhat-ethers");
require("@nomiclabs/hardhat-etherscan");
require("@nomiclabs/hardhat-waffle");

const key = process.env.KEY

module.exports = {
  networks: {
    hardhat: {},
    live: {
      chainId: 250,
      gasPrice: 100000000000,
      url: "https://rpcapi-tracing.fantom.network/",
      accounts: [key]
    },
  },
  etherscan: {
    apiKey: process.env.API
  },
  solidity: {
    compilers: [{
      version: "0.8.7",
      settings: {
        optimizer: {
          enabled: true,
          runs: 200
        }
      },
    }],
  }
};