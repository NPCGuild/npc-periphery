// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "../interfaces/IRarity.sol";
import "../interfaces/IGold.sol";
import "../interfaces/IRarityERC20.sol";

/**
 * @dev RarityExchange is a place on which summoners can submit trade offers for any
 * ERC20-like element for the rarity ecosystem.
 */
contract RarityExchange {

    // =============================================== Storage ========================================================

    /// @dev Trade is an element offered by a summoner in exchange for gold.
    /// @param summoner The summoner owner of the product.
    /// @param from The user owner of the summoner.
    /// @param price The amount of gold requested for the item.
    /// @param collection The item contract where the information is stored.
    /// @param amount The amount of elements on the collection the trade includes.
    /// @param fulfilled Boolean if the trade is fulfilled.
    /// @param trade_id The internal id number.
    struct Trade {
        uint256 summoner;
        address from;
        uint256 price;
        address collection;
        uint256 amount;
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
    /// ( collection ) => ( user => Trade )
    mapping(address => mapping (address => Trade)) elements;

    // =============================================== Events =========================================================

    /// @dev SubmitTrade is emitted with the `submitTrade` function.
    /// This event should be indexed to have a full list of products.
    /// @param summoner The summoner owner of the product.
    /// @param from The user owner of the summoner.
    /// @param price The amount of gold requested for the item.
    /// @param collection The item contract where the information is stored.
    /// @param amount The amount of elements on the collection the trade includes.
    /// @param trade_id The internal id number.
    event SubmitTrade(
        uint256 summoner,
        address from,
        uint256 price,
        address indexed collection,
        uint256 amount,
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
    /// @param amount The amount of elements on the collection the trade includes.
    /// @param trade_id The internal id number.
    event TradeExecuted(
        address from,
        address to,
        uint256 summoner_from,
        uint256 summoner_to,
        uint256 price,
        address indexed collection,
        uint256 amount,
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
    /// @param amount The amount of elements on the collection the trade includes.
    /// @param price The amount of gold requested for the item.
    /// @param _owner The summoner owner of the product.
    function submitTrade(address _collection, uint256 amount, uint256 price, uint256 _owner) external returns (uint256) {
        require(_collection != address(0), "RarityExchange: Cannot use empty address for tradeableItemContract");
        require(price > 0, "RarityExchange: Unable to submit trade with price 0");
        require(IRarityERC20(_collection).allowance(_owner, owner_summoner) >= amount, "RarityExchange: Market Owner is not approved for spend");
        require(rarity.ownerOf(_owner) == msg.sender, "RarityExchange: sender is not summoner owner");

        trades += 1;
        uint256 tradeId = trades;


        Trade memory t = Trade(_owner, msg.sender, price, _collection, amount, false, tradeId);
        elements[_collection][msg.sender] = t;

        emit SubmitTrade(_owner, msg.sender, price, _collection, amount, tradeId);

        return tradeId;
    }

    /// @dev buyTrade is the main function to purchase a trade request.
    /// @param _collection The item contract where the information is stored.
    /// @param _user The address of the user that submitted the trade to purchase to.
    /// @param receiverSummoner The buyer summoner
    function buyTrade(address _collection, address _user, uint256 receiverSummoner) external returns (bool) {
        require(_collection != address(0), "RarityExchange: Cannot use empty address for tradeableItemContract");

        Trade memory t = elements[_collection][_user];
        require(!t.fulfilled, "RarityExchange: Trade is already fullfilled");

        require(gold.transferFrom(owner_summoner, receiverSummoner, t.summoner, t.price), "RarityExchange: Unable to transfer gold seller");
        elements[_collection][_user].fulfilled = true;

        require(IRarityERC20(_collection).transferFrom(owner_summoner, t.summoner, receiverSummoner, t.amount), "RarityExchange: Unable to transfer item to buyer");

        emit TradeExecuted(t.from, msg.sender, t.summoner, receiverSummoner, t.price, _collection, t.amount, t.trade_id);

        return true;
    }

    // =============================================== Getters ========================================================

    /// @dev getTradeInformation returns the information for an item on a _collection.
    /// @param _collection The item contract where the information is stored.
    /// @param _user The address of the user that submitted the trade to purchase to.
    function getTradeInformation(address _collection, address _user) external view returns (Trade memory) {
        return elements[_collection][_user];
    }
}
