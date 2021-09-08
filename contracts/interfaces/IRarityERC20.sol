// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

/**
   @dev IRarityERC20 is a common interface for developers to build ERC20-like items.
   Since the Rarity ecosystem intends to have its own internal economy, is critical for
   all items inside the economy to work around the same economical model.
   This means all items must be traded between summoners, not users. To achieve that, any
   item that complies with the following interface is sellable in the RarityCollectiblesMarket.
 */
interface IRarityERC20 {

    /** transferFrom Necessary to make sure the summoner owner of the market is
        able to transfer the trade element from the seller to the buyer.
    */
    function transferFrom(uint executor, uint from, uint to, uint id) external view returns (bool);

    /** approve Users require to approve the summoner owner for trades.
    */
    function approve(uint from, uint spender, uint id) external view returns (bool);

    /** allowance To check if the market owner is approved to spend a specific item.
    */
    function allowance(uint from, uint spender) external view returns (uint256);
}