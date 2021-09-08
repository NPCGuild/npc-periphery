describe('RarityExchange', () => {

    before(async () => {

        const [gold, material] = await ethers.getSigners()

        const Exchange = await ethers.getContractFactory("RarityExchange");
        const MockRarity = await ethers.getContractFactory("MockRarity");
        const MockGold = await ethers.getContractFactory("MockRarityGold");
        const MockMaterial = await ethers.getContractFactory("MockRarityMaterial");

        this.rarity = await MockRarity.deploy();
        await this.rarity.deployed()

        await this.rarity.summon(1, {from: gold.address})
        await this.rarity.summon(1, {from: material.address})

        this.gold = await MockGold.deploy(this.rarity.address);
        await this.gold.deployed()

        this.material = await MockMaterial.deploy(this.rarity.address);
        await this.material.deployed()

        this.exchange = await Exchange.deploy(this.rarity.address, 1, this.gold.address)
        await this.exchange.deployed()
    });

    it('make sure everything is correct', async () => {

        console.log("hello")
    });


});