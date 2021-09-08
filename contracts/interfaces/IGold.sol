// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

interface IGold {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    function transferFrom(uint executor, uint from, uint to, uint amount) external view returns (bool);
    function approve(uint from, uint spender, uint amount) external view returns (bool);
    function transfer(uint from, uint to, uint amount) external view returns (bool);
    function claimable(uint summoner) external view returns (uint amount);
    function wealth_by_level(uint level) external pure returns (uint wealth);
    function balanceOf(uint summoner) external pure returns (uint balance);
}
