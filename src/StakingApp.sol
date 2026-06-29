// SPDX-License-Identifier: MIT
pragma solidity 0.8.35;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract StakingApp is Ownable {

    // 1. Stakingtoken address
    // 2. Admin account

    // Variables
    address public StakingToken;

    // Events

    // Modifiers

    // Constructor
    constructor (address StakingToken_, address initialOwner) Ownable(initialOwner) {
        StakingToken = StakingToken_;
    }

    // Functions






}