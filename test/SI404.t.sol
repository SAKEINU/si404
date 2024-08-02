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
        uint200 maxERC721Transfer,
        address initialOwner,
        address initialMintRecipient
    )
        SI404(
            name,
            symbol,
            decimals,
            maxTotalSupplyERC721,
            maxERC721Transfer,
            initialOwner,
            initialMintRecipient
        )
    {}

    // Expose the internal mint function for testing
    function testMintERC20(address to, uint256 value) public {
        _mintERC20(to, value);
    }

    function testTransferERC721(
        address from,
        address to,
        uint256 tokenId
    ) public {
        transferFrom(from, to, tokenId);
    }
}

contract SI404Test is Test {
    TestableSI404 si404;
    address owner;
    address initialMinter;
    address userA;
    uint8 constant test_decimals = 18;
    uint32 constant test_units = 100_000;
    uint32 constant test_maxTotalSupplyERC721 = 10_000;
    uint32 constant test_maxERC721Transfer = 1_00;
    uint256 constant test_scaledUnits = test_units * 10 ** test_decimals;

    uint256 idPrefix;

    function setUp() public {
        owner = makeAddr("owner");
        initialMinter = makeAddr("initialMinter");
        userA = makeAddr("userA");
        vm.prank(owner);
        si404 = new TestableSI404(
            "SI404",
            "SI",
            test_decimals,
            test_maxTotalSupplyERC721,
            test_maxERC721Transfer,
            owner,
            initialMinter
        );
        idPrefix = si404.ID_ENCODING_PREFIX();
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
        assertEq(
            si404.erc20BalanceOf(initialMinter),
            test_maxTotalSupplyERC721 * test_units * (10 ** test_decimals)
        );
        // Check if user A has exactly zero NFT
        assertEq(si404.erc721BalanceOf(initialMinter), 0);

        // Test fractional values, ensure no NFT minted
        vm.prank(owner);
        si404.testMintERC20(userA, 9999 * 10 ** test_decimals); // Slightly less than the required for 1 NFT
        assertEq(si404.erc20BalanceOf(userA), 9999 * 10 ** test_decimals);
        assertEq(si404.erc721BalanceOf(userA), 0);
    }

    function testFractionalERC20NoMint() public {
        // Give user A a fractional value below the NFT minting threshold
        vm.prank(owner);
        si404.testMintERC20(userA, 5000 * 10 ** test_decimals); // Half the amount required for 1 NFT
        assertEq(si404.erc20BalanceOf(userA), 5000 * 10 ** test_decimals);
        assertEq(si404.erc721BalanceOf(userA), 0);
    }

    function testMaxERC721TransferExceeded() public {
        vm.prank(initialMinter);
        si404.transfer(userA, (test_maxERC721Transfer) * test_scaledUnits);
        assertEq(
            si404.erc20BalanceOf(userA),
            (test_maxERC721Transfer) * test_scaledUnits
        );

        vm.prank(initialMinter);
        vm.expectRevert();
        si404.transfer(userA, (test_maxERC721Transfer + 1) * test_scaledUnits);

        vm.prank(owner);
        si404.setMaxERC721Transfer((test_maxERC721Transfer - 1));
        assertEq(si404.maxERC721Transfer(), test_maxERC721Transfer - 1);

        vm.prank(initialMinter);
        vm.expectRevert();
        si404.transfer(userA, (test_maxERC721Transfer) * test_scaledUnits);

        address userB = makeAddr("userB");
        vm.prank(userB);
        si404.setSelfERC721TransferExempt(true);
        assertEq(si404.erc721TransferExempt(userB), true);

        vm.prank(initialMinter);
        si404.transfer(userB, (test_maxERC721Transfer * 10) * test_scaledUnits);
        assertEq(
            si404.erc20BalanceOf(userB),
            (test_maxERC721Transfer * 10) * test_scaledUnits
        );
    }

    function testERC721Lock() public {
        // Give user A a fractional value below the NFT minting threshold
        vm.prank(owner);
        uint256 nfts = 10;
        uint256 balance = nfts * test_scaledUnits;
        si404.testMintERC20(userA, balance);

        uint256 lockedId = 0;
        uint256[] memory ids;
        for (uint256 i = 0; i < nfts; i++) {
            vm.prank(userA);
            lockedId = (10 - i) + (idPrefix);
            si404.erc721Lock(lockedId);
            ids = si404.owned(userA);
            assertEq(ids[i], lockedId);
            vm.expectRevert();
            si404.testTransferERC721(userA, owner, lockedId);

            // user cannot spend erc20 combined with locked erc721
            vm.prank(userA);
            vm.expectRevert();
            si404.transfer(owner, (nfts - i) * test_scaledUnits);
        }

        vm.prank(userA);
        uint256 unlockedId = (nfts / 2) + (idPrefix);
        si404.erc721Unlock(unlockedId);
        ids = si404.owned(userA);
        assertEq(ids[ids.length - 1], unlockedId);

        vm.prank(userA);
        si404.transfer(owner, test_scaledUnits);
        ids = si404.owned(userA);
        assertEq(ids.length, nfts - 1);
        // must send the unlockedId first
        for (uint256 i = 0; i < ids.length; i++) {
            assertNotEq(ids[i], unlockedId);
        }
    }

    function testERC72Unlock() public {
        // Give user A a fractional value below the NFT minting threshold
        vm.prank(owner);
        uint256 nfts = 10;
        uint256 balance = nfts * test_scaledUnits;
        si404.testMintERC20(userA, balance);

        uint256 target = 0;
        uint256[] memory ids;
        for (uint256 i = 0; i < nfts; i++) {
            vm.prank(userA);
            target = (10 - i) + (idPrefix);
            si404.erc721Lock(target);
        }

        for (uint256 i = 0; i < nfts; i++) {
            vm.prank(userA);
            target = (i + 1) + (idPrefix);
            si404.erc721Unlock(target);
            ids = si404.owned(userA);
            assertEq(ids[ids.length - 1], target);

            vm.prank(userA);
            si404.testTransferERC721(userA, owner, target);
        }
        assertEq(si404.balanceOf(userA), 0);
    }
}
