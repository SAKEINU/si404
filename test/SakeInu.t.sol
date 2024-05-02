// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {SakeInu} from "../contracts/SakeInu.sol";

// Extend the SakeInu contract to expose internal functions for testing
contract TestableSakeInu is SakeInu {
    constructor(
        string memory name,
        string memory symbol,
        uint8 decimals,
        uint256 maxTotalSupplyERC721,
        address initialOwner,
        address initialMintRecipient
    ) SakeInu(name, symbol, decimals, maxTotalSupplyERC721, initialOwner, initialMintRecipient) {}

    // Expose the internal mint function for testing
    function testMintERC20(address to, uint256 value) public {
        _mintERC20(to, value);
    }
}

contract SakeInuTest is Test {
    TestableSakeInu sakeInu;
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
        sakeInu = new TestableSakeInu("SakeInu", "SI", test_decimals, test_maxTotalSupplyERC721, owner, initialMinter);
    }

    function testOnlyOwnerCanSetBaseURI() public {
        string memory newURI = "https://newapi.sakeinu.com/metadata/";

        // Owner can set
        vm.prank(owner);
        sakeInu.setBaseURI(newURI);
        assertEq(sakeInu.baseURI(), newURI);

        // initialMinter cannot set
        vm.prank(initialMinter);
        vm.expectRevert(); // Expect any revert
        sakeInu.setBaseURI(newURI);

        // User A cannot set
        vm.prank(userA);
        vm.expectRevert(); // Expect any revert
        sakeInu.setBaseURI(newURI);
    }

    function testTokenNFTMintingRatio() public {
        assertEq(sakeInu.erc20BalanceOf(initialMinter), test_maxTotalSupplyERC721 * test_units * (10 ** test_decimals));
        // Check if user A has exactly zero NFT
        assertEq(sakeInu.erc721BalanceOf(initialMinter), 0);

        // Test fractional values, ensure no NFT minted
        vm.prank(owner);
        sakeInu.testMintERC20(userA, 9999 * 10 ** test_decimals); // Slightly less than the required for 1 NFT
        assertEq(sakeInu.erc20BalanceOf(userA), 9999 * 10 ** test_decimals);
        assertEq(sakeInu.erc721BalanceOf(userA), 0);
    }

    function testFractionalERC20NoMint() public {
        // Give user B a fractional value below the NFT minting threshold
        vm.prank(owner);
        sakeInu.testMintERC20(userA, 5000 * 10 ** test_decimals); // Half the amount required for 1 NFT
        assertEq(sakeInu.erc20BalanceOf(userA), 5000 * 10 ** test_decimals);
        assertEq(sakeInu.erc721BalanceOf(userA), 0);
    }
}
