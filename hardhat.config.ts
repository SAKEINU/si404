import dotenv from "dotenv";
import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "tsconfig-paths/register";
import "@nomicfoundation/hardhat-foundry";


dotenv.config();

const config: HardhatUserConfig = {
  solidity: {
    compilers: [
      {
        version: "0.8.25",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        }
      }
    ],
  },
};

/**
 * Extract env vars
 */
const privateKey = process.env.PRIVATE_KEY || "";

/**
 * If private key is available, attach network configs
 */
if (privateKey) {
  config.networks = {
    sei_arctic_1: {
      url: "https://evm-rpc-arctic-1.sei-apis.com/",
      chainId: 713715,
      accounts: [privateKey],
      gas: "auto",
      gasPrice: "auto",
    },
    sei_atlantic_2: {
      url: "https://evm-rpc-testnet.sei-apis.com/",
      chainId: 1328,
      accounts: [privateKey],
      gas: "auto",
      gasPrice: "auto",
    },
    sei_pacific_1:  {
      url: "https://evm-rpc.sei-apis.com/",
      chainId: 1329,
      accounts: [privateKey],
      gas: "auto",
      gasPrice: "auto",
    }
  };
}

/**
 * Load etherscan key
 */
const seitraceKey = process.env.SEITRACE_KEY || "";

if (seitraceKey) {
  config.etherscan = {
    apiKey: {
      sei_arctic_1: seitraceKey,
      sei_atlantic_2: seitraceKey,
      sei_pacific_1: seitraceKey,
    },
    customChains: [
      {
        network: "sei_arctic_1",
        chainId: 713715,
        urls: {
          apiURL: "https://seitrace.com/arctic-1/api",
          browserURL: "https://seitrace.com"
        }
      },
      {
        network: "sei_atlantic_2",
        chainId: 1328,
        urls: {
          apiURL: "https://seitrace.com/atlantic-2/api",
          browserURL: "https://seitrace.com"
        }
      },
      {
        network: "sei_pacific_1",
        chainId: 1329,
        urls: {
          apiURL: "https://seitrace.com/pacific-1/api",
          browserURL: "https://seitrace.com"
        }
      },

    ],
  };
}

export default config;
