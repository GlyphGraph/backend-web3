import {
  loadFixture
} from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { assert } from "chai";
import hre from "hardhat";

describe("GlyphGraph", function () {
  async function deployContract() {
    const [owner, otherAccount] = await hre.ethers.getSigners();
    const Lock = await hre.ethers.getContractFactory("GlyphGraph");
    const gg = await Lock.deploy();
    console.log("owner", owner.address)
    return { gg, owner, otherAccount };
  }

  describe("Deployment", function () {
    it("The contract should be deployed", async function () {
      const { gg, } = await loadFixture(deployContract);
      assert(gg !== null)
    })
  });

  describe("User", () => {
    it("The user1 should be created", async () => {
      const { gg } = await loadFixture(deployContract)
      const { data } = await gg.createUser("Name", "email@gmail.com", "123")
      console.log(data)
      assert(data !== null)
    })

    it("The user2 should be created", async () => {
      const { gg } = await loadFixture(deployContract)
      const { data } = await gg.createUser("Name", "email1@gmail.com", "123")
      console.log(data)
      assert(data !== null)
    })

    it("Get the user",  async () => {
      const { gg } = await loadFixture(deployContract)
      const user = await gg.getUser();
      console.log(user)
      assert(user !== null)
    })
  })

  describe("Vault", () => {
    it("The vault should be created", async () => {
      const { gg } = await loadFixture(deployContract)
      const { data } = await gg.createVault("v1")
      assert(data !== null)
    })
  })
});
