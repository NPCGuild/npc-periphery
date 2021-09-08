require("dotenv").config()

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