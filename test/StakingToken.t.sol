// SPDX-License-Identifier: MIT
pragma solidity 0.8.35;

import {Test} from "forge-std/Test.sol";
import {StakingToken} from "../src/StakingToken.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract StakingTokenTest is Test {
    StakingToken stakingToken;
    string name = "StakingToken";
    string symbol = "STK";
    address account;

    function setUp() public {
        account = vm.addr(1);
        stakingToken = new StakingToken(name, symbol);
    }

    function testMintCorrectly() public {
        vm.startPrank(account);
        uint256 amount_ = 1 ether;
        uint256 balanceBefore = IERC20(address(stakingToken)).balanceOf(account);
        stakingToken.mint(amount_);
        uint256 balanceAfter = IERC20(address(stakingToken)).balanceOf(account);
        assert(balanceAfter - balanceBefore == amount_);
        vm.stopPrank();
    }
}
