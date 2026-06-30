// SPDX-License-Identifier: MIT
pragma solidity 0.8.35;

import {Test} from "forge-std/Test.sol";
import {StakingToken} from "../src/StakingToken.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract StakingTokenTest is Test {

    StakingToken stakingToken;

    string public name = "StakingToken";
    string public symbol = "STK";
    // address public admin_;

    function setUp() public {
        // admin_ = vm.addr(1);
        stakingToken = new StakingToken(name, symbol);
    }

    function testMint() public{
        uint256 amount_ = 1 ether;

        stakingToken.mint(amount_);
    }


}