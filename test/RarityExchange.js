const { expect } = require("chai");

describe('RarityExchange', () => {

    before(async () => {

        const [gold, material] = await ethers.getSigners()

        this.goldOwner = gold;
        this.materialOwner = material;

        const Exchange = await ethers.getContractFactory("RarityExchange");
        const MockRarity = await ethers.getContractFactory("MockRarity");
        const MockGold = await ethers.getContractFactory("MockRarityGold");
        const MockMaterial = await ethers.getContractFactory("MockRarityMaterial");

        this.rarity = await MockRarity.deploy();
        await this.rarity.deployed()

        await this.rarity.connect(gold).summon(1)
        await this.rarity.connect(material).summon(1)

        this.gold = await MockGold.deploy(this.rarity.address);
        await this.gold.deployed()

        this.material = await MockMaterial.deploy(this.rarity.address);
        await this.material.deployed()

        this.exchange = await Exchange.deploy(this.rarity.address, 2, this.gold.address)
        await this.exchange.deployed()
    });

    it('make sure everything is correct', async () => {

        // Check gold balance
        const goldBalance = await this.gold.balanceOf(0)
        expect(goldBalance.toString(), "100000000000000000000")

        // Check material balance
        const materialBalance = await this.material.balanceOf(0)
        expect(materialBalance.toString(), "100000000000000000000")

        // Check summoners ownership
        const goldOwner = await this.rarity.ownerOf(0)
        expect(goldOwner, this.goldOwner.address)

        const materialOwner = await this.rarity.ownerOf(1)
        expect(materialOwner, this.materialOwner.address)
    });


});