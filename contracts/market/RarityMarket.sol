// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "../interfaces/IRarity.sol";
import "../interfaces/IGold.sol";

/**
 * @dev RarityMarket is a place on which summoners can submit trade offers for any
 * element being used around the Rarity ecosystem.
 */
contract RarityMarket {

    // =============================================== Storage ========================================================

    /// @dev Trade is an element offered by a summoner in exchange for gold.
    /// @param summoner The summoner owner of the product.
    /// @param from The user owner of the summoner.
    /// @param price The amount of gold requested for the item.
    /// @param tradeable_items_contract The item contract where the information is stored.
    /// @param id The id of the item inside the item contract.
    /// @param fulfilled Boolean if the trade is fulfilled.
    struct Trade {
        uint256 summoner;
        address from;
        uint256 price;
        address tradeable_items_contract;
        uint256 id;
        bool fulfilled;
    }

    /// @dev rarity is the implementation of the rarity contract.
    IRarity public rarity;

    /// @dev gold is the implementation of the rarity gold contract.
    IGold public gold;

    /// @dev owner_summoner is the summoner in charge of running the market.
    /// Is necessary to send the items to the owner to be able to submit a trade order.
    uint256 public owner_summoner;

    /// @dev elements is where all trades are stores.
    /// ( tradeable_items_contract) => ( users => Trades[] )
    mapping(address => mapping (address => Trade[])) elements;

    // =============================================== Events =========================================================

    /// @dev SubmitTrade is emitted with the `submitTrade` function.
    /// This event should be indexed to have a full list of products.
    /// @param summoner The summoner owner of the product.
    /// @param from The user owner of the summoner.
    /// @param price The amount of gold requested for the item.
    /// @param tradeable_items_contract The item contract where the information is stored.
    /// @param id The id of the item inside the item contract.
    event SubmitTrade(
        uint256 summoner,
        address from,
        uint256 price,
        address indexed tradeable_items_contract,
        uint256 indexed id
    );

    /// @dev TradeExecuted is emitted with the `buyTrade` function.
    /// This event should be indexed to get executed trades and volume of the market.
    /// @param from The user owner of the summoner that sold the product.
    /// @param to The user owner of the summoner that bought the product.
    /// @param summoner_from The summoner that sold the product.
    /// @param summoner_to The summoner that bought the product.
    /// @param price The amount of gold requested for the item.
    /// @param tradeable_items_contract The item contract where the information is stored.
    /// @param id The id of the item inside the item contract.
    event TradeExecuted(
        address from,
        address to,
        uint256 summoner_from,
        uint256 summoner_to,
        uint256 price,
        address indexed tradeable_items_contract,
        uint256 indexed id
    );

    // ============================================== Modifiers =======================================================
    // =============================================== Setters ========================================================

    /// @dev Constructor
    /// @param _rarity The address of the rarity contract.
    constructor(address _rarity, uint256 _owner) {
        rarity = IRarity(_rarity);
        owner_summoner = _owner;
    }

    // =============================================== Getters ========================================================

}
