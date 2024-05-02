// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC404} from "erc404/ERC404.sol";
import {Strings} from "openzeppelin-contracts/contracts/utils/Strings.sol";
import {Ownable} from "openzeppelin-contracts/contracts/access/Ownable.sol";

contract SakeInu is ERC404, Ownable {
    string private _baseURI;

    constructor(
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        uint256 maxTotalSupplyERC721_,
        address initialOwner_,
        address initialMintRecipient_
    ) ERC404(name_, symbol_, decimals_) Ownable(initialOwner_) {
        // Do not mint the ERC721s to the initial owner, as it's a waste of gas.
        _setERC721TransferExempt(initialMintRecipient_, true);
        _mintERC20(initialMintRecipient_, maxTotalSupplyERC721_ * _unit());
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_isValidTokenId(tokenId), "ERC721Metadata: URI query for invalid token");

        string memory base = baseURI();
        require(bytes(base).length != 0, "ERC721 is not revealed yet");

        return string(abi.encodePacked(base, Strings.toString(tokenId - ID_ENCODING_PREFIX), ".json"));
    }

    function _unit() internal view override returns (uint256) {
        return 10_000 * (10 ** uint256(decimals));
    }

    function baseURI() public view virtual returns (string memory) {
        return _baseURI;
    }

    function _setBaseURI(string memory baseURI_) internal virtual {
        _baseURI = baseURI_;
    }

    ////////////////////////////////////////////////////////////////
    //                      ADMIN FUNCTIONS                       //
    ////////////////////////////////////////////////////////////////
    function setBaseURI(string memory baseURI_) public onlyOwner {
        _setBaseURI(baseURI_);
    }

    function setERC721TransferExempt(address account_, bool value_) external onlyOwner {
        _setERC721TransferExempt(account_, value_);
    }
}
