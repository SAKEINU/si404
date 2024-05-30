// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {SI404} from "../contracts/SI404.sol";

// Extend the SI404 contract to expose internal functions for testing
contract TestableSI404 is SI404 {
    constructor(
        string memory name,
        string memory symbol,
        uint8 decimals,
        uint256 maxTotalSupplyERC721,
        address initialOwner,
        address initialMintRecipient
    ) SI404(name, symbol, decimals, maxTotalSupplyERC721, initialOwner, initialMintRecipient) {}

    // Expose the internal mint function for testing
    function testMintERC20(address to, uint256 value) public {
        _mintERC20(to, value);
    }
}

contract SI404Test is Test {
    TestableSI404 si404;
    address owner;
    address initialMinter;
    address userA;
    uint8 constant test_decimals = 18;
    uint16 constant test_units = 10_000;
    uint32 constant test_maxTotalSupplyERC721 = 100_000;

    function setUp() public {
        owner = makeAddr("owner");
        initialMinter = makeAddr("initialMinter");
        userA = makeAddr("userA");
        vm.prank(owner);
        si404 = new TestableSI404("SI404", "SI", test_decimals, test_maxTotalSupplyERC721, owner, initialMinter);
    }

    function testOnlyOwnerCanSetBaseURI() public {
        string memory newURI = "https://newapi.si404.com/metadata/";

        // Owner can set
        vm.prank(owner);
        si404.setBaseURI(newURI);
        assertEq(si404.baseURI(), newURI);

        // initialMinter cannot set
        vm.prank(initialMinter);
        vm.expectRevert(); // Expect any revert
        si404.setBaseURI(newURI);

        // User A cannot set
        vm.prank(userA);
        vm.expectRevert(); // Expect any revert
        si404.setBaseURI(newURI);
    }

    function testTokenNFTMintingRatio() public {
        assertEq(si404.erc20BalanceOf(initialMinter), test_maxTotalSupplyERC721 * test_units * (10 ** test_decimals));
        // Check if user A has exactly zero NFT
        assertEq(si404.erc721BalanceOf(initialMinter), 0);

        // Test fractional values, ensure no NFT minted
        vm.prank(owner);
        si404.testMintERC20(userA, 9999 * 10 ** test_decimals); // Slightly less than the required for 1 NFT
        assertEq(si404.erc20BalanceOf(userA), 9999 * 10 ** test_decimals);
        assertEq(si404.erc721BalanceOf(userA), 0);
    }

    function testFractionalERC20NoMint() public {
        // Give user B a fractional value below the NFT minting threshold
        vm.prank(owner);
        si404.testMintERC20(userA, 5000 * 10 ** test_decimals); // Half the amount required for 1 NFT
        assertEq(si404.erc20BalanceOf(userA), 5000 * 10 ** test_decimals);
        assertEq(si404.erc721BalanceOf(userA), 0);
    }
}
