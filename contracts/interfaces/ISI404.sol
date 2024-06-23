//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ISI404 {
    // ERC-721 lock/unlock functions
    function erc721Lock(uint256 id_) external;
    function erc721Unlock(uint256 id_) external;

    // Admin functions
    function setBaseURI(string memory baseURI_) external;
    function setMaxERC721Transfer(uint256 value_) external;
}
