// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import "../contracts/SakeInu.sol";

contract SakeInuScript is Script {
    function run(address owner_, address initialMinter_) external {
        vm.startBroadcast();
        new SakeInu("SakeInu", "SI", 18, 100_000, owner_, initialMinter_);
        vm.stopBroadcast();
    }

    function selfExemptionList(address sakeInuAddr_, bool state_) external {
        vm.startBroadcast();
        console.log(">>> selfExemptionList");
        console.log("Address of sender: ", msg.sender);
        SakeInu sakeInu = SakeInu(sakeInuAddr_);
        sakeInu.setSelfERC721TransferExempt(state_);
        vm.stopBroadcast();
    }

    function setBaseURI(address sakeInuAddr_, string memory baseURI) external {
        vm.startBroadcast();
        console.log(">>> setBaseURI");
        console.log("Address of sender: ", msg.sender);
        SakeInu sakeInu = SakeInu(sakeInuAddr_);
        sakeInu.setBaseURI(baseURI);
        vm.stopBroadcast();
    }

    function setERC721TransferExempt(address sakeInuAddr_, address account, bool _state) external {
        vm.startBroadcast();
        console.log(">>> setERC721TransferExempt");
        console.log("Address of sender: ", msg.sender);
        console.log("Account: ", account, " state: ", _state);
        SakeInu sakeInu = SakeInu(sakeInuAddr_);
        sakeInu.setERC721TransferExempt(account, _state);
        vm.stopBroadcast();
    }
}
