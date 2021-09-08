const { expect } = require("chai");

describe('RarityExchange', () => {

    before(async () => {

        const [gold, material, exchange] = await ethers.getSigners()

        this.goldOwner = gold;
        this.materialOwner = material;
        this.exchangeOwner = exchange;

        const Exchange = await ethers.getContractFactory("RarityExchange");
        const MockRarity = await ethers.getContractFactory("MockRarity");
        const MockGold = await ethers.getContractFactory("MockRarityGold");
        const MockMaterial = await ethers.getContractFactory("MockRarityMaterial");

        this.rarity = await MockRarity.deploy();
        await this.rarity.deployed()

        await this.rarity.connect(gold).summon(1)
        await this.rarity.connect(material).summon(1)
        await this.rarity.connect(exchange).summon(1)

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

        const exchangeOwner = await this.rarity.ownerOf(2)
        expect(exchangeOwner, this.exchangeOwner.address)
    });

    it('submit trade', async () => {
        // User should give rarity approval for the exchange
        await this.rarity.connect(this.materialOwner).setApprovalForAll(this.exchange.address, true)

        // Approve trader owner to spend 10 material
        await this.material.connect(this.materialOwner).approve(1, 2, "10000000000000000000")

        await this.exchange.connect(this.materialOwner).submitTrade(this.material.address, "10000000000000000000", "10000000000000000000", 1)
    });

    it('get trade information', async () => {

        const trades = await this.exchange.trades()
        expect(trades, "1")

        const trade = await this.exchange.getTradeInformation(this.material.address, this.materialOwner.address)
        expect(trade.from, this.material.address)
        expect(trade.price, "10000000000000000000")
        expect(trade.collection, this.material.address)
        expect(trade.amount, "10000000000000000000")
        expect(trade.fulfilled, false)
        expect(trade.trade_id, '1')

    });

    it('buy the trade', async () => {
        await this.rarity.connect(this.goldOwner).setApprovalForAll(this.exchange.address, true)

        await this.gold.connect(this.goldOwner).approve(0, 2, "10000000000000000000")

        // Approve trader owner to spend 10 material
        await this.exchange.connect(this.goldOwner).buyTrade(this.material.address, this.materialOwner.address, 0)

    });


});