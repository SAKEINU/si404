// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC404} from "erc404/ERC404.sol";
import {Strings} from "openzeppelin-contracts/contracts/utils/Strings.sol";
import {Ownable} from "openzeppelin-contracts/contracts/access/Ownable.sol";
import {ISI404} from "./interfaces/ISI404.sol";

contract SI404 is ERC404, ISI404, Ownable {
    uint256 public maxERC721Transfer;

    string public baseURI;

    /// @dev ERC-721 Tokens that are locked
    mapping(uint256 => bool) public locked;

    /// @dev The number of lockedTokens for a given address
    mapping(address => uint256) public lockedTokens;

    constructor(
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        uint256 maxTotalSupplyERC721_,
        uint256 maxERC721Transfer_,
        address initialOwner_,
        address initialMintRecipient_
    ) ERC404(name_, symbol_, decimals_) Ownable(initialOwner_) {
        // Do not mint the ERC721s to the initial owner, as it's a waste of gas.
        maxERC721Transfer = maxERC721Transfer_;
        _setERC721TransferExempt(initialMintRecipient_, true);
        _mintERC20(initialMintRecipient_, maxTotalSupplyERC721_ * _unit());
    }

    function _unit() internal view override returns (uint256) {
        return 100_000 * (10 ** uint256(decimals));
    }

    function tokenURI(
        uint256 tokenId
    ) public view virtual override returns (string memory) {
        require(
            _isValidTokenId(tokenId),
            "ERC721Metadata: URI query for invalid token"
        );

        require(bytes(baseURI).length != 0, "ERC721 is not revealed yet");

        return
            string(
                abi.encodePacked(
                    baseURI,
                    Strings.toString(tokenId - ID_ENCODING_PREFIX),
                    ".json"
                )
            );
    }

    function erc721Lock(uint256 id_) public virtual {
        if (_getOwnerOf(id_) != msg.sender) {
            revert Unauthorized();
        }

        if (locked[id_]) {
            return;
        }

        delete getApproved[id_];

        uint256 lockCandidateIndex = _getOwnedIndex(id_);
        uint256 firstUnlockedIndex = lockedTokens[msg.sender];
        _swapERC721(msg.sender, lockCandidateIndex, firstUnlockedIndex);

        lockedTokens[msg.sender]++;
        locked[id_] = true;
    }

    function erc721Unlock(uint256 id_) external virtual {
        if (_getOwnerOf(id_) != msg.sender) {
            revert Unauthorized();
        }

        if (!locked[id_]) {
            return;
        }

        uint256 lockedIndex = _getOwnedIndex(id_);
        uint256 lastLockedIndex = lockedTokens[msg.sender] - 1;

        _swapERC721(msg.sender, lockedIndex, lastLockedIndex);

        delete locked[id_];
        lockedTokens[msg.sender]--;
    }

    function _transferERC721(
        address from_,
        address to_,
        uint256 id_
    ) internal virtual override {
        require(
            !locked[id_],
            string.concat("SI404: ", Strings.toString(id_), " is locked")
        );
        ERC404._transferERC721(from_, to_, id_);
    }

    ////////////////////////////////////////////////////////////////
    //                      ADMIN FUNCTIONS                       //
    ////////////////////////////////////////////////////////////////
    function setBaseURI(string memory baseURI_) external virtual onlyOwner {
        _setBaseURI(baseURI_);
    }

    function setERC721TransferExempt(
        address account_,
        bool value_
    ) external virtual onlyOwner {
        _setERC721TransferExempt(account_, value_);
    }

    function setMaxERC721Transfer(uint256 value_) external virtual onlyOwner {
        maxERC721Transfer = value_;
    }

    ////////////////////////////////////////////////////////////////
    //                      INTERNAL FUNCTIONS                    //
    ////////////////////////////////////////////////////////////////
    function _setBaseURI(string memory baseURI_) internal virtual {
        baseURI = baseURI_;
    }

    function _swapERC721(
        address owner,
        uint256 fromIdx_,
        uint256 toIdx_
    ) internal virtual {
        if (fromIdx_ == toIdx_) {
            return;
        }

        (_owned[owner][fromIdx_], _owned[owner][toIdx_]) = (
            _owned[owner][toIdx_],
            _owned[owner][fromIdx_]
        );

        uint256 fromId = _owned[owner][fromIdx_];
        uint256 toId = _owned[owner][toIdx_];

        _setOwnedIndex(fromId, fromIdx_);
        _setOwnedIndex(toId, toIdx_);
    }

    /// @notice Internal function for ERC-20 transfers. Also handles any ERC-721 transfers that may be required.
    // Handles ERC-721 exemptions.
    function _transferERC20WithERC721(
        address from_,
        address to_,
        uint256 value_
    ) internal virtual override returns (bool) {
        if (!erc721TransferExempt(from_) || !erc721TransferExempt(to_)) {
            require(
                (value_ / _unit()) <= maxERC721Transfer,
                string.concat(
                    "SI404: Max ERC721 transfer (",
                    Strings.toString(maxERC721Transfer),
                    ") exceeded"
                )
            );
        }
        return ERC404._transferERC20WithERC721(from_, to_, value_);
    }
}
