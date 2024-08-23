// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {SI404} from "./SI404.sol";

contract SAKEINU is SI404 {
    address initialOwner = 0x5873AFDec732b7DFFcE3b71A98FF7F253bC5BB35;
    address initialMinter = 0x4C1283f020C6bcF89C46A1aBE754A4D264257b25;
    constructor()
        SI404("SAKEINU", "SAKE", 18, 10_000, 150, initialOwner, initialMinter)
    {}
}
