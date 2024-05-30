// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import "../contracts/SI404.sol";

contract SI404Script is Script {
    function run(address owner_, address initialMinter_) external {
        vm.startBroadcast();
        new SI404("SI404", "SI", 18, 100_000, owner_, initialMinter_);
        vm.stopBroadcast();
    }

    function selfExemptionList(address si404Addr_, bool state_) external {
        vm.startBroadcast();
        console.log(">>> selfExemptionList");
        console.log("Address of sender: ", msg.sender);
        SI404 si404 = SI404(si404Addr_);
        si404.setSelfERC721TransferExempt(state_);
        vm.stopBroadcast();
    }

    function setBaseURI(address si404Addr_, string memory baseURI) external {
        vm.startBroadcast();
        console.log(">>> setBaseURI");
        console.log("Address of sender: ", msg.sender);
        SI404 si404 = SI404(si404Addr_);
        si404.setBaseURI(baseURI);
        vm.stopBroadcast();
    }

    function setERC721TransferExempt(address si404Addr_, address account, bool _state) external {
        vm.startBroadcast();
        console.log(">>> setERC721TransferExempt");
        console.log("Address of sender: ", msg.sender);
        console.log("Account: ", account, " state: ", _state);
        SI404 si404 = SI404(si404Addr_);
        si404.setERC721TransferExempt(account, _state);
        vm.stopBroadcast();
    }
}
