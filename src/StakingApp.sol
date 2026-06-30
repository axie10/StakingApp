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
    constructor(address StakingToken_, address owner_) Ownable(owner_) {
        StakingToken = StakingToken_;
    }

    // Functions

    // Try functions inherited of Ownable
    function getOwner() external view returns (address) {
        address v = Ownable.owner();
        return v;
    }

    function getOwner2() external view onlyOwner returns (address) {
        address v = Ownable.owner();
        return v;
    }
}
