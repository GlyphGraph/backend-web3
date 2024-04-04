import "@nomicfoundation/hardhat-toolbox";
import { HardhatUserConfig } from "hardhat/config";
import { PRIVATE_KEY } from "./config";


const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.20",
    settings: {
      optimizer: {
        enabled: true
      }
    }
  },
  networks: {
    xdc: {
      url: "https://erpc.apothem.network/",
      accounts: [PRIVATE_KEY]
    }
  }
};

export default config;
