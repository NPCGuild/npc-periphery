// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "../interfaces/IRarity.sol";
import "../interfaces/IGold.sol";
import "../interfaces/IRarityERC721.sol";

/**
 * @dev RarityMarket is a place on which summoners can submit trade offers for any
 * ERC721-like element for the rarity ecosystem.
 */
contract RarityMarket {

    // =============================================== Storage ========================================================

    /// @dev Trade is an element offered by a summoner in exchange for gold.
    /// @param summoner The summoner owner of the product.
    /// @param from The user owner of the summoner.
    /// @param price The amount of gold requested for the item.
    /// @param collection The item contract where the information is stored.
    /// @param id The id of the item inside the item contract.
    /// @param fulfilled Boolean if the trade is fulfilled.
    /// @param trade_id The internal id number.
    struct Trade {
        uint256 summoner;
        address from;
        uint256 price;
        address collection;
        uint256 id;
        bool fulfilled;
        uint256 trade_id;
    }

    /// @dev rarity is the implementation of the rarity contract.
    IRarity public rarity;

    /// @dev gold is the implementation of the rarity gold contract.
    IGold public gold;

    /// @dev trades the amount of trades in the contract to use as id.
    uint256 public trades;

    /// @dev owner_summoner is the summoner in charge of running the market.
    /// Is necessary to send the items to the owner to be able to submit a trade order.
    uint256 public owner_summoner;

    /// @dev elements is where all trades are stored.
    /// ( collection ) => ( item_id => Trade )
    mapping(address => mapping (uint256 => Trade)) elements;

    // =============================================== Events =========================================================

    /// @dev SubmitTrade is emitted with the `submitTrade` function.
    /// This event should be indexed to have a full list of products.
    /// @param summoner The summoner owner of the product.
    /// @param from The user owner of the summoner.
    /// @param price The amount of gold requested for the item.
    /// @param collection The item contract where the information is stored.
    /// @param id The id of the item inside the item contract.
    /// @param trade_id The internal id number.
    event SubmitTrade(
        uint256 summoner,
        address from,
        uint256 price,
        address indexed collection,
        uint256 indexed id,
        uint256 indexed trade_id
    );

    /// @dev TradeExecuted is emitted with the `buyTrade` function.
    /// This event should be indexed to get executed trades and volume of the market.
    /// @param from The user owner of the summoner that sold the product.
    /// @param to The user owner of the summoner that bought the product.
    /// @param summoner_from The summoner that sold the product.
    /// @param summoner_to The summoner that bought the product.
    /// @param price The amount of gold requested for the item.
    /// @param collection The item contract where the information is stored.
    /// @param id The id of the item inside the item contract.
    /// @param trade_id The internal id number.
    event TradeExecuted(
        address from,
        address to,
        uint256 summoner_from,
        uint256 summoner_to,
        uint256 price,
        address indexed collection,
        uint256 indexed id,
        uint256 indexed trade_id
    );

    // =============================================== Setters ========================================================

    /// @dev Constructor
    /// @param _rarity The address of the rarity contract.
    /// @param _owner The summoner owner of the market.
    /// @param _gold The rarity gold address.
    constructor(address _rarity, uint256 _owner, address _gold) {
        rarity = IRarity(_rarity);
        owner_summoner = _owner;
        gold = IGold(_gold);
    }

    /// @dev submitTrade is the main function to start an item trade.
    /// @param _collection The item contract where the information is stored.
    /// @param id The id of the item inside the item contract.
    /// @param price The amount of gold requested for the item.
    /// @param _owner The summoner owner of the product.
    function submitTrade(address _collection, uint256 id, uint256 price, uint256 _owner) external returns (uint256) {
        require(_collection != address(0), "RarityMarket: Cannot use empty address for tradeableItemContract");
        require(price > 0, "RarityMarket: Unable to submit trade with price 0");
        require(IRarityERC721(_collection).ownerOf(id) == _owner, "RarityMarket: summoner is not the owner");
        require(rarity.ownerOf(_owner) == msg.sender, "RarityMarket: require sender to be owner of the owner summoner");
        require(IRarityERC721(_collection).IsApproved(_owner, owner_summoner, id), "RarityMarket: Market Owner is not approved for spend");

        uint256 tradeId = trades + 1;
        trades += 1;

        Trade memory t = Trade(_owner, msg.sender, price, _collection, id, false, tradeId);
        elements[_collection][id] = t;

        emit SubmitTrade(_owner, msg.sender, price, _collection, id, tradeId);

        return tradeId;
    }

    /// @dev buyTrade is the main function to purchase a trade request.
    /// @param _tradeableItemsContract The item contract where the information is stored.
    /// @param id The id of the item inside the item contract.
    /// @param receiverSummoner The buyer summoner
    function buyTrade(address _tradeableItemsContract, uint256 id, uint256 receiverSummoner) external returns (bool) {
        require(_tradeableItemsContract != address(0), "RarityMarket: Cannot use empty address for tradeableItemContract");

        Trade memory t = elements[_tradeableItemsContract][id];
        require(!t.fulfilled, "RarityMarket: Trade is already fullfilled");

        require(gold.transferFrom(owner_summoner, t.summoner, receiverSummoner, t.price), "RarityMarket: Unable to transfer gold seller");
        elements[_tradeableItemsContract][id].fulfilled = true;

        require(IRarityERC721(_tradeableItemsContract).transferFrom(owner_summoner, t.summoner, receiverSummoner, id), "RarityMarket: Unable to transfer item to buyer");

        emit TradeExecuted(t.from, msg.sender, t.summoner, receiverSummoner, t.price, _tradeableItemsContract, id, t.trade_id);

        return true;
    }

    // =============================================== Getters ========================================================

    /// @dev getTradeInformation returns the information for an item on a tradeable_items_contract.
    /// @param _tradeableItemsContract The item contract where the information is stored.
    /// @param id The id of the item inside the item contract.
    function getTradeInformation(address _tradeableItemsContract, uint256 id) external view returns (Trade memory) {
        return elements[_tradeableItemsContract][id];
    }
}
