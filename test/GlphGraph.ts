import {
    loadFixture
} from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { assert } from "chai";
import hre from "hardhat";

describe("GlyphGraph", function () {
    enum PasswordType {
        RANDOM,
        MEMORABLE
    }

    async function deployContract() {
        const [owner, otherAccount] = await hre.ethers.getSigners();
        const Lock = await hre.ethers.getContractFactory("GlyphGraph");
        const gg = await Lock.deploy();
        console.log("owner", owner.address)
        return { gg, owner, otherAccount };
    }

    async function createUser() {
        const contract = await deployContract()
        await contract.gg.addUser("Name", "email@gmail.com", "123")
        return contract;
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
            const { data } = await gg.addUser("Name", "email@gmail.com", "123")
            const user = await gg.getUserDetails();
            console.log(user)
            assert(user !== null)
        })

        it("The user2 should be created", async () => {
            const { gg } = await loadFixture(deployContract)
            const { data } = await gg.addUser("Name", "email1@gmail.com", "123")
            const user = await gg.getUserDetails();
            console.log(user)
            assert(user !== null)
        })
    })

    describe("Vault", () => {
        it("The vault1 should be created", async () => {
            const { gg, owner } = await loadFixture(createUser)
            await gg.createVault("v1")
            await gg.createVaultWithPassword("v2", "password123")
            const data = await gg.getAllVaults()
            console.log(data)
            assert(data !== null)
        })
    })
});
