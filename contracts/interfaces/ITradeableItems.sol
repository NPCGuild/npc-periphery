// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

/**
   @dev ITradeableItems is a common interface for developers to build tradeable items.
   Since the Rarity ecosystem intends to have its own internal economy, is critical for
   all items inside the economy to work around the same economical model.
   This means all items must be traded between summoners, not users. To achieve that, any
   item that complies with the following interface is sellable in the RarityMarket.
 */
interface ITradeableItems {

    /** transferFrom Necessary to make sure the summoner owner of the market is
        able to transfer the trade element from the seller to the buyer.
    */
    function transferFrom(uint executor, uint from, uint to, uint amount) external view returns (bool);

    /** approve Users require to approve the summoner owner for trades
    */
    function approve(uint from, uint spender, uint amount) external view returns (bool);

    /** setApprovalForAll Is an optional feature that will make easier to list
        multiple products in the market with full ownership of the summoner market owner.
    */
    function setApprovalForAll(uint from, uint spender) external view returns (bool);

    /** ownerOf Is required to verify the ownership of the item.
        (probably not necessary because of allowance, but still preferred)
    */
    function ownerOf(uint item) external view returns (uint summoner);
}